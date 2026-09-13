-- ==============================================================================
-- 16_fix_store_settings_and_size_presets.sql
-- Fixes & Optimizations for Classic Collection Solapur:
-- 1. Store Settings (Global Delivery Fees & Free Shipping Threshold)
-- 2. Master Size Presets Table (Pre-seeded with Cloth Material Cut Lengths)
-- 3. Product Variants In-Stock Availability Column (is_in_stock)
-- ==============================================================================

-- 1. STORE SETTINGS (Global Delivery Fees & Threshold)
CREATE TABLE IF NOT EXISTS public.store_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_fee NUMERIC(10, 2) DEFAULT 60.00,
    free_shipping_above NUMERIC(10, 2) DEFAULT 999.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure at least one default row exists
INSERT INTO public.store_settings (delivery_fee, free_shipping_above)
SELECT 1.00, 999.00
WHERE NOT EXISTS (SELECT 1 FROM public.store_settings);

-- Enable RLS and grant full public read/write access
ALTER TABLE public.store_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public Full Store Settings" ON public.store_settings;
CREATE POLICY "Public Full Store Settings" ON public.store_settings FOR ALL TO public USING (true) WITH CHECK (true);

-- 2. PRODUCT VARIANTS (Availability column for 1-click stock toggles)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'product_variants' 
        AND column_name = 'is_in_stock'
    ) THEN
        ALTER TABLE public.product_variants ADD COLUMN is_in_stock BOOLEAN DEFAULT TRUE;
    END IF;
END $$;

-- 3. MASTER SIZE PRESETS (Fabric Cut Lengths in Meters)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS public.size_presets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type TEXT NOT NULL CHECK (type IN ('standard', 'suit', 'custom', 'alpha', 'numeric')),
    size_label TEXT NOT NULL,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_type_size UNIQUE (type, size_label)
);

-- Seed Standard Cut Lengths (1.2M - 2.5M)
INSERT INTO public.size_presets (type, size_label, display_order, is_active)
VALUES
    ('standard', '1.2M', 1, TRUE),
    ('standard', '1.4M', 2, TRUE),
    ('standard', '1.6M', 3, TRUE),
    ('standard', '1.8M', 4, TRUE),
    ('standard', '2.0M', 5, TRUE),
    ('standard', '2.25M', 6, TRUE),
    ('standard', '2.5M', 7, TRUE)
ON CONFLICT (type, size_label) DO NOTHING;

-- Seed Suit & Blazer Cut Lengths (2.8M - 5.0M)
INSERT INTO public.size_presets (type, size_label, display_order, is_active)
VALUES
    ('suit', '2.8M', 8, TRUE),
    ('suit', '3.0M', 9, TRUE),
    ('suit', '3.25M', 10, TRUE),
    ('suit', '3.5M', 11, TRUE),
    ('suit', '4.0M', 12, TRUE),
    ('suit', '5.0M', 13, TRUE)
ON CONFLICT (type, size_label) DO NOTHING;

ALTER TABLE public.size_presets ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public View Size Presets" ON public.size_presets;
CREATE POLICY "Public View Size Presets" ON public.size_presets FOR SELECT TO public USING (true);

DROP POLICY IF EXISTS "Full Access Size Presets" ON public.size_presets;
CREATE POLICY "Full Access Size Presets" ON public.size_presets FOR ALL TO public USING (true) WITH CHECK (true);

-- 4. GRANT TABLE ACCESS
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;
