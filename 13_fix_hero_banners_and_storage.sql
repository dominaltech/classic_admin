-- ==============================================================================
-- 13_fix_hero_banners_and_storage.sql
-- Fixes Hero Banner Upload & PostgreSQL Integer Overflow
-- Author: Classic Collection System
-- ==============================================================================

-- 1. ENSURE BANNERS TABLE EXISTS WITH BIGINT DISPLAY ORDER
CREATE TABLE IF NOT EXISTS public.banners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    subtitle TEXT,
    image_url TEXT NOT NULL,
    mobile_image_url TEXT,
    link_url TEXT DEFAULT '#',
    badge_text TEXT,
    display_order BIGINT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. ALTER COLUMN TO BIGINT IF IT ALREADY EXISTS AS INT (CRITICAL FIX FOR Date.now() OVERFLOW)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'banners' 
          AND column_name = 'display_order'
          AND data_type = 'integer'
    ) THEN
        ALTER TABLE public.banners ALTER COLUMN display_order TYPE BIGINT;
    END IF;
END $$;

-- 3. ENSURE ALL COLUMNS EXIST
ALTER TABLE public.banners ADD COLUMN IF NOT EXISTS subtitle TEXT;
ALTER TABLE public.banners ADD COLUMN IF NOT EXISTS mobile_image_url TEXT;
ALTER TABLE public.banners ADD COLUMN IF NOT EXISTS link_url TEXT DEFAULT '#';
ALTER TABLE public.banners ADD COLUMN IF NOT EXISTS badge_text TEXT;
ALTER TABLE public.banners ADD COLUMN IF NOT EXISTS display_order BIGINT DEFAULT 0;
ALTER TABLE public.banners ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- 4. ROW LEVEL SECURITY (RLS) FOR BANNERS TABLE
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public Full Banners" ON public.banners;
DROP POLICY IF EXISTS "Public Read Active Banners" ON public.banners;
DROP POLICY IF EXISTS "Admin Full Banners" ON public.banners;
DROP POLICY IF EXISTS "Anon Full Banners" ON public.banners;
DROP POLICY IF EXISTS "Authenticated Full Banners" ON public.banners;

CREATE POLICY "Public Full Banners" ON public.banners 
    FOR ALL TO public 
    USING (true) 
    WITH CHECK (true);

CREATE POLICY "Anon Full Banners" ON public.banners 
    FOR ALL TO anon 
    USING (true) 
    WITH CHECK (true);

CREATE POLICY "Authenticated Full Banners" ON public.banners 
    FOR ALL TO authenticated 
    USING (true) 
    WITH CHECK (true);

-- 5. STORAGE BUCKETS SETUP (banner-images & product-images)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('product-images', 'product-images', true, 26214400, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/svg+xml']),
  ('banner-images', 'banner-images', true, 26214400, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/svg+xml'])
ON CONFLICT (id) DO UPDATE SET 
  public = true,
  file_size_limit = 26214400,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/svg+xml'];

-- 6. STORAGE OBJECTS RLS POLICIES FOR BOTH BUCKETS
DROP POLICY IF EXISTS "Public Read Product Images" ON storage.objects;
DROP POLICY IF EXISTS "Public Insert Product Images" ON storage.objects;
DROP POLICY IF EXISTS "Public Update Product Images" ON storage.objects;
DROP POLICY IF EXISTS "Public Delete Product Images" ON storage.objects;
DROP POLICY IF EXISTS "Public Full Storage Access" ON storage.objects;
DROP POLICY IF EXISTS "Public Full Banners Storage" ON storage.objects;

CREATE POLICY "Public Full Storage Access"
ON storage.objects FOR ALL
TO public
USING (bucket_id IN ('product-images', 'banner-images'))
WITH CHECK (bucket_id IN ('product-images', 'banner-images'));

CREATE POLICY "Anon Full Storage Access"
ON storage.objects FOR ALL
TO anon
USING (bucket_id IN ('product-images', 'banner-images'))
WITH CHECK (bucket_id IN ('product-images', 'banner-images'));

CREATE POLICY "Authenticated Full Storage Access"
ON storage.objects FOR ALL
TO authenticated
USING (bucket_id IN ('product-images', 'banner-images'))
WITH CHECK (bucket_id IN ('product-images', 'banner-images'));

-- 7. SEED INITIAL HERO BANNERS IF TABLE IS CURRENTLY EMPTY
INSERT INTO public.banners (title, subtitle, image_url, link_url, badge_text, display_order, is_active)
SELECT 'CLASSIC COLLECTION STREETWEAR', '240 GSM COMBED COTTON · LUXURY OVERSIZED FIT', 'images/banner1.jpg', 'shop.html', 'EXCLUSIVE SHOWCASE', 1, true
WHERE NOT EXISTS (SELECT 1 FROM public.banners LIMIT 1);

INSERT INTO public.banners (title, subtitle, image_url, link_url, badge_text, display_order, is_active)
SELECT 'EVERYDAY LUXURY CO-ORDS', 'PREMIUM DROP SHOULDER · EARTH TONE ESSENTIALS', 'images/banner2.jpg', 'shop.html', 'NEW ARRIVAL', 2, true
WHERE (SELECT COUNT(*) FROM public.banners) < 2;

INSERT INTO public.banners (title, subtitle, image_url, link_url, badge_text, display_order, is_active)
SELECT 'MINIMALIST STREET CULTURE', 'HEAVYWEIGHT WASHED DENIM & CARGOS', 'images/banner3.jpg', 'shop.html', 'LIMITED EDITION', 3, true
WHERE (SELECT COUNT(*) FROM public.banners) < 3;
