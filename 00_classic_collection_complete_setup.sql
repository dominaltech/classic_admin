-- ==============================================================================
-- CLASSIC COLLECTION SOLAPUR - COMPLETE SUPABASE DATABASE SETUP
-- Brand: Classic Collection Solapur (classicsolapur.com)
-- Domain: Premium Cloth Materials (Suiting, Shirting, Cotton, Linen, Khadi, Silk)
-- ==============================================================================

-- Enable UUID extension safely with proper quotes
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. PROFILES
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    phone TEXT,
    address TEXT,
    pincode TEXT,
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    default_address JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CATEGORIES / MATERIAL TYPES
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    image_url TEXT,
    banner_url TEXT,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. PRODUCTS (CLOTH MATERIALS)
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    details JSONB DEFAULT '[]'::jsonb,
    price NUMERIC(10, 2) NOT NULL,
    mrp NUMERIC(10, 2) NOT NULL,
    main_image TEXT NOT NULL,
    is_featured BOOLEAN DEFAULT FALSE,
    is_new_arrival BOOLEAN DEFAULT TRUE,
    status TEXT DEFAULT 'published' CHECK (status IN ('draft', 'published', 'archived')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. PRODUCT VARIANTS (FABRIC CUT LENGTHS / SIZES)
CREATE TABLE IF NOT EXISTS public.product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    size TEXT NOT NULL, -- e.g. 1.2M, 1.6M, 2.5M, 3.0M, Standard Cut
    color TEXT DEFAULT 'Default',
    sku TEXT UNIQUE,
    stock_quantity INT NOT NULL DEFAULT 20,
    price_override NUMERIC(10, 2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. PRODUCT GALLERY IMAGES
CREATE TABLE IF NOT EXISTS public.product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    display_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. HERO BANNERS (HOMEPAGE BANNER SLIDER)
CREATE TABLE IF NOT EXISTS public.banners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    subtitle TEXT,
    image_url TEXT NOT NULL,
    mobile_image_url TEXT,
    link_url TEXT DEFAULT '#',
    badge_text TEXT,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. COUPONS
CREATE TABLE IF NOT EXISTS public.coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    discount_type TEXT DEFAULT 'percentage' CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value NUMERIC(10, 2) NOT NULL,
    min_order_amount NUMERIC(10, 2) DEFAULT 0,
    max_discount_amount NUMERIC(10, 2),
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. ORDERS
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number TEXT NOT NULL UNIQUE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    shipping_address JSONB NOT NULL,
    subtotal NUMERIC(10, 2) NOT NULL,
    discount_amount NUMERIC(10, 2) DEFAULT 0,
    shipping_fee NUMERIC(10, 2) DEFAULT 0,
    total_amount NUMERIC(10, 2) NOT NULL,
    payment_status TEXT DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING', 'PAID', 'FAILED', 'REFUNDED')),
    order_status TEXT DEFAULT 'PLACED' CHECK (order_status IN ('PLACED', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED')),
    cashfree_order_id TEXT UNIQUE,
    tracking_number TEXT,
    courier_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. ORDER ITEMS
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    variant_size TEXT,
    variant_color TEXT,
    unit_price NUMERIC(10, 2) NOT NULL,
    quantity INT NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. PAYMENTS
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
    cashfree_order_id TEXT NOT NULL,
    cashfree_payment_id TEXT,
    payment_mode TEXT,
    payment_status TEXT NOT NULL,
    payment_amount NUMERIC(10, 2) NOT NULL,
    raw_payload JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. ADMIN PWA PUSH SUBSCRIPTIONS
CREATE TABLE IF NOT EXISTS public.admin_push_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_agent TEXT,
    endpoint TEXT NOT NULL UNIQUE,
    keys JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. STORE SETTINGS
CREATE TABLE IF NOT EXISTS public.store_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_fee NUMERIC(10, 2) DEFAULT 60.00,
    free_shipping_above NUMERIC(10, 2) DEFAULT 999.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS CONFIGURATION
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_push_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_settings ENABLE ROW LEVEL SECURITY;

-- CLEAN EXISTING POLICIES
DROP POLICY IF EXISTS "Public Full Profiles" ON public.profiles;
DROP POLICY IF EXISTS "Public Full Categories" ON public.categories;
DROP POLICY IF EXISTS "Public Full Products" ON public.products;
DROP POLICY IF EXISTS "Public Full Product Variants" ON public.product_variants;
DROP POLICY IF EXISTS "Public Full Product Images" ON public.product_images;
DROP POLICY IF EXISTS "Public Full Banners" ON public.banners;
DROP POLICY IF EXISTS "Public Full Coupons" ON public.coupons;
DROP POLICY IF EXISTS "Public Full Orders" ON public.orders;
DROP POLICY IF EXISTS "Public Full Order Items" ON public.order_items;
DROP POLICY IF EXISTS "Public Full Payments" ON public.payments;
DROP POLICY IF EXISTS "Public Full Push Subscriptions" ON public.admin_push_subscriptions;
DROP POLICY IF EXISTS "Public Full Store Settings" ON public.store_settings;

-- POLICIES ALLOWING PUBLIC READ & ADMIN FULL ACCESS
CREATE POLICY "Public Full Profiles" ON public.profiles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Full Categories" ON public.categories FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Full Products" ON public.products FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Full Product Variants" ON public.product_variants FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Full Product Images" ON public.product_images FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Full Banners" ON public.banners FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Full Coupons" ON public.coupons FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Full Orders" ON public.orders FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Full Order Items" ON public.order_items FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Full Payments" ON public.payments FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Full Push Subscriptions" ON public.admin_push_subscriptions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Full Store Settings" ON public.store_settings FOR ALL USING (true) WITH CHECK (true);

-- SEED DATA: CLOTH MATERIAL CATEGORIES
INSERT INTO public.categories (id, name, slug, description, image_url, display_order)
VALUES 
  ('c1000000-0000-0000-0000-000000000001', 'Suiting', 'suiting', 'Men''s Premium Formal & Safari Suiting Material', 'images/hero1.jpg', 1),
  ('c1000000-0000-0000-0000-000000000002', 'Shirting', 'shirting', 'Luxury Shirting Fabrics - Checks, Solids & Stripes', 'images/hero2.jpg', 2),
  ('c1000000-0000-0000-0000-000000000003', 'Cotton', 'cotton', '100% Pure Combed & Giza Cotton Fabrics', 'images/hero3.jpg', 3),
  ('c1000000-0000-0000-0000-000000000004', 'Linen', 'linen', 'Pure & Blended Lightweight Breathable Linen', 'images/prod1.jpg', 4),
  ('c1000000-0000-0000-0000-000000000005', 'Khadi', 'khadi', 'Authentic Handspun Handloom Khadi Materials', 'images/prod2.jpg', 5),
  ('c1000000-0000-0000-0000-000000000006', 'Silk', 'silk', 'Traditional & Luxury Handloom Silk Fabrics', 'images/prod3.jpg', 6),
  ('c1000000-0000-0000-0000-000000000007', 'Test Items', 'test-items', 'Testing & Verification Material Cut', 'images/logo.jpg', 99)
ON CONFLICT (slug) DO UPDATE SET 
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url;

-- SEED DATA: HERO BANNERS
INSERT INTO public.banners (title, subtitle, image_url, link_url, badge_text, display_order, is_active)
VALUES
  ('CLASSIC MEN''S FORMAL FABRICS', 'PREMIUM COTTON, LINEN & KHADI SUITING MATERIALS', 'images/hero1.jpg', 'suiting.html', 'NEW ARRIVALS 2026', 1, true),
  ('EXCLUSIVE HANDLOOM SILK & KHADI', 'TRADITIONAL TEXTILES CRAFTED WITH LUXURY FINISH', 'images/hero2.jpg', 'khadi.html', 'POPULAR WEAVE', 2, true),
  ('CASUAL SHIRTING & LINEN COTTON', 'BREATHABLE WEAVES DESIGNED FOR TIMELESS COMFORT', 'images/hero3.jpg', 'shirting.html', 'LIMITED EDITION', 3, true)
ON CONFLICT DO NOTHING;

-- SEED DATA: SAMPLE CLOTH MATERIAL PRODUCTS
INSERT INTO public.products (id, category_id, name, slug, description, price, mrp, main_image, is_featured, is_new_arrival, status)
VALUES
  (
    'a1000000-0000-0000-0000-000000000000',
    'c1000000-0000-0000-0000-000000000007',
    'Classic ₹1 Sample Material Swatch',
    'classic-1-rupee-test-product',
    'Live Cashfree payment verification and material cut sample swatch.',
    1.00,
    50.00,
    'images/logo.jpg',
    true,
    true,
    'published'
  ),
  (
    'a1000000-0000-0000-0000-000000000001',
    'c1000000-0000-0000-0000-000000000001',
    'Italian Wool Blend Charcoal Suiting Cloth',
    'italian-wool-blend-charcoal-suiting',
    'Premium rich wool blend formal suiting material with fine drape and wrinkle resistance. Ideal for blazers and trousers.',
    1299.00,
    2499.00,
    'images/hero1.jpg',
    true,
    true,
    'published'
  ),
  (
    'a1000000-0000-0000-0000-000000000002',
    'c1000000-0000-0000-0000-000000000002',
    'Pure Irish Linen Sky Blue Shirting Cloth',
    'pure-irish-linen-sky-blue-shirting',
    'Luxurious 60 LEA pure linen fabric. Highly breathable, soft washed, and exceptionally comfortable for formal and casual shirts.',
    999.00,
    1899.00,
    'images/hero2.jpg',
    true,
    true,
    'published'
  ),
  (
    'a1000000-0000-0000-0000-000000000003',
    'c1000000-0000-0000-0000-000000000003',
    'Egyptian Giza Cotton Crisp White Fabric',
    'egyptian-giza-cotton-crisp-white',
    'Long-staple pure Giza cotton cloth with silky luster and high durability. Classic choice for executive shirts.',
    799.00,
    1499.00,
    'images/hero3.jpg',
    true,
    false,
    'published'
  ),
  (
    'a1000000-0000-0000-0000-000000000004',
    'c1000000-0000-0000-0000-000000000005',
    'Traditional Handloom Natural Khadi Cloth',
    'traditional-handloom-natural-khadi',
    'Hand-spun and hand-woven organic khadi fabric. Natural textured feel with authentic ethnic drape.',
    649.00,
    1199.00,
    'images/prod1.jpg',
    false,
    true,
    'published'
  )
ON CONFLICT (slug) DO NOTHING;

-- SEED DATA: VARIANTS (FABRIC CUT LENGTHS)
INSERT INTO public.product_variants (product_id, size, color, stock_quantity)
VALUES
  ('a1000000-0000-0000-0000-000000000000', 'SAMPLE', 'White', 9999),
  ('a1000000-0000-0000-0000-000000000001', '1.2M (Trouser)', 'Charcoal', 25),
  ('a1000000-0000-0000-0000-000000000001', '2.0M (Blazer)', 'Charcoal', 20),
  ('a1000000-0000-0000-0000-000000000001', '3.0M (Full Suit)', 'Charcoal', 15),
  ('a1000000-0000-0000-0000-000000000002', '1.6M (Shirt)', 'Sky Blue', 30),
  ('a1000000-0000-0000-0000-000000000002', '2.25M (Full Cut)', 'Sky Blue', 20),
  ('a1000000-0000-0000-0000-000000000003', '1.6M (Shirt)', 'White', 40),
  ('a1000000-0000-0000-0000-000000000003', '2.5M (Kurta)', 'White', 25),
  ('a1000000-0000-0000-0000-000000000004', '1.6M (Shirt)', 'Natural Beige', 35),
  ('a1000000-0000-0000-0000-000000000004', '2.5M (Kurta)', 'Natural Beige', 20)
ON CONFLICT DO NOTHING;

-- SEED DATA: COUPONS
INSERT INTO public.coupons (code, discount_type, discount_value, min_order_amount)
VALUES ('CLASSIC10', 'percentage', 10.00, 499.00)
ON CONFLICT (code) DO NOTHING;

-- SEED DATA: DEFAULT STORE SETTINGS
INSERT INTO public.store_settings (delivery_fee, free_shipping_above)
VALUES (60.00, 999.00)
ON CONFLICT DO NOTHING;
