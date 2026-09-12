-- 14_auto_confirm_users_no_email_verification.sql
-- AUTOMATICALLY CONFIRM ALL NEW USERS & DISABLE EMAIL CONFIRMATION REQUIREMENTS
-- CLASSIC COLLECTION SOLAPUR

-- ==============================================================================
-- 1. TRIGGER FUNCTION TO AUTO-CONFIRM USERS UPON CREATION (IN auth.users)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.auto_confirm_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Automatically set email_confirmed_at so no verification link is needed.
  -- Note: confirmed_at is a GENERATED column in Postgres and updates automatically from email_confirmed_at.
  NEW.email_confirmed_at = COALESCE(NEW.email_confirmed_at, now());
  
  -- Clear any confirmation token requirements
  NEW.confirmation_token = NULL;
  NEW.confirmation_sent_at = NULL;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. ATTACH BEFORE INSERT TRIGGER ON auth.users
DROP TRIGGER IF EXISTS on_auth_user_auto_confirm ON auth.users;
CREATE TRIGGER on_auth_user_auto_confirm
  BEFORE INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_confirm_new_user();

-- 3. ATTACH BEFORE UPDATE TRIGGER ON auth.users (IN CASE CONFIRMATION IS RESET)
DROP TRIGGER IF EXISTS on_auth_user_auto_confirm_update ON auth.users;
CREATE TRIGGER on_auth_user_auto_confirm_update
  BEFORE UPDATE ON auth.users
  FOR EACH ROW
  WHEN (NEW.email_confirmed_at IS NULL)
  EXECUTE FUNCTION public.auto_confirm_new_user();

-- ==============================================================================
-- 4. RPC FUNCTION TO CONFIRM ANY USER ACCOUNT BY EMAIL OR USER ID
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.confirm_user_account(user_email TEXT)
RETURNS JSONB AS $$
DECLARE
  v_user_id UUID;
BEGIN
  UPDATE auth.users
  SET email_confirmed_at = COALESCE(email_confirmed_at, now()),
      confirmation_token = NULL
  WHERE LOWER(email) = LOWER(user_email)
  RETURNING id INTO v_user_id;

  IF v_user_id IS NOT NULL THEN
    -- Ensure profile also exists
    INSERT INTO public.profiles (id, full_name, role)
    VALUES (v_user_id, split_part(user_email, '@', 1), 'user')
    ON CONFLICT (id) DO NOTHING;

    RETURN jsonb_build_object('success', true, 'user_id', v_user_id, 'message', 'User confirmed successfully');
  ELSE
    RETURN jsonb_build_object('success', false, 'message', 'User not found');
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.confirm_user_account(TEXT) TO anon, authenticated, service_role;

-- ==============================================================================
-- 5. ENSURE PROFILE AUTO-CREATION TRIGGER IS ACTIVE & ROBUST
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, phone, address, pincode, role, created_at, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1), 'Classic Customer'),
    COALESCE(NEW.raw_user_meta_data->>'phone', ''),
    COALESCE(NEW.raw_user_meta_data->>'address', ''),
    COALESCE(NEW.raw_user_meta_data->>'pincode', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'user'),
    now(),
    now()
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    phone = CASE WHEN EXCLUDED.phone <> '' THEN EXCLUDED.phone ELSE public.profiles.phone END,
    updated_at = now();
    
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ==============================================================================
-- 6. RETROACTIVELY CONFIRM ALL EXISTING UNCONFIRMED USERS
-- ==============================================================================
UPDATE auth.users
SET email_confirmed_at = COALESCE(email_confirmed_at, now()),
    confirmation_token = NULL
WHERE email_confirmed_at IS NULL;

-- Backfill any missing profiles for auth users
INSERT INTO public.profiles (id, full_name, phone, role, created_at, updated_at)
SELECT 
  u.id,
  COALESCE(u.raw_user_meta_data->>'full_name', split_part(u.email, '@', 1), 'Classic Customer'),
  COALESCE(u.raw_user_meta_data->>'phone', ''),
  'user',
  u.created_at,
  now()
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = u.id);

-- ==============================================================================
-- 7. NOTE FOR SUPABASE DASHBOARD AUTH SETTING:
-- To permanently turn off email confirmations in Supabase GoTrue Auth:
-- 1. Open Supabase Dashboard -> Authentication -> Providers -> Email
-- 2. Toggle "Confirm email" to OFF
-- 3. Click "Save"
-- ==============================================================================
