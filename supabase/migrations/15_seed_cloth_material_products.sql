-- ====================================================================
-- CLASSIC COLLECTION SOLAPUR — AUTHENTIC CLOTH MATERIAL PRODUCTS SEED
-- Covers all 6 categories: Suiting, Shirting, Cotton, Linen, Khadi, Silk
-- Includes Cut-Length Variants: 1.2M, 1.6M, 2.0M, 2.5M, 3.0M
-- ====================================================================

DO $$
DECLARE
  cat_suiting UUID := 'c1000000-0000-0000-0000-000000000001';
  cat_shirting UUID := 'c1000000-0000-0000-0000-000000000002';
  cat_cotton UUID := 'c1000000-0000-0000-0000-000000000003';
  cat_linen UUID := 'c1000000-0000-0000-0000-000000000004';
  cat_khadi UUID := 'c1000000-0000-0000-0000-000000000005';
  cat_silk UUID := 'c1000000-0000-0000-0000-000000000006';
  base_img TEXT := 'https://mizbiarhnxzrpfuodqnj.supabase.co/storage/v1/object/public/product-images/products';
  p_id UUID;
BEGIN

  -- 1. SUITING - Italian Worsted Poly-Viscose
  INSERT INTO public.products (name, slug, category_id, price, mrp, description, main_image, is_featured, is_new_arrival, status)
  VALUES ('Italian Worsted Poly-Viscose Suiting Material', 'italian-worsted-poly-viscose-suiting-material', cat_suiting, 1499.00, 2499.00,
          'Premium 420 GSM Italian worsted poly-viscose bespoke suit length fabric. Wrinkle-resistant with a rich matte drape for formal blazers, bandhgalas and trousers.',
          base_img || '/1788943956158_iyxrft_1000225547_webp.webp', true, true, 'published')
  ON CONFLICT (slug) DO UPDATE SET price = EXCLUDED.price, mrp = EXCLUDED.mrp
  RETURNING id INTO p_id;

  INSERT INTO public.product_variants (product_id, size, sku, stock_quantity)
  VALUES 
    (p_id, '1.2M', SUBSTRING(p_id::text, 1, 8) || '-12M', 30),
    (p_id, '1.6M', SUBSTRING(p_id::text, 1, 8) || '-16M', 30),
    (p_id, '2.0M', SUBSTRING(p_id::text, 1, 8) || '-20M', 25),
    (p_id, '2.5M', SUBSTRING(p_id::text, 1, 8) || '-25M', 20),
    (p_id, '3.0M', SUBSTRING(p_id::text, 1, 8) || '-30M', 15)
  ON CONFLICT (sku) DO NOTHING;

  -- 2. SUITING - Royal Imperial Charcoal Tweed
  INSERT INTO public.products (name, slug, category_id, price, mrp, description, main_image, is_featured, is_new_arrival, status)
  VALUES ('Royal Imperial Charcoal Tweed Suiting Fabric', 'royal-imperial-charcoal-tweed-suiting-fabric', cat_suiting, 1899.00, 2999.00,
          'Luxurious heavy-weave tweed suiting cloth with charcoal herringbone finish. Engineered for bespoke two-piece suits and tailored winter coats.',
          base_img || '/1788943887863_ge0uuh_1000225545_webp.webp', true, true, 'published')
  ON CONFLICT (slug) DO UPDATE SET price = EXCLUDED.price, mrp = EXCLUDED.mrp
  RETURNING id INTO p_id;

  INSERT INTO public.product_variants (product_id, size, sku, stock_quantity)
  VALUES 
    (p_id, '1.2M', SUBSTRING(p_id::text, 1, 8) || '-12M', 30),
    (p_id, '1.6M', SUBSTRING(p_id::text, 1, 8) || '-16M', 30),
    (p_id, '2.0M', SUBSTRING(p_id::text, 1, 8) || '-20M', 25),
    (p_id, '2.5M', SUBSTRING(p_id::text, 1, 8) || '-25M', 20),
    (p_id, '3.0M', SUBSTRING(p_id::text, 1, 8) || '-30M', 15)
  ON CONFLICT (sku) DO NOTHING;

  -- 3. SHIRTING - Egyptian Giza Cotton
  INSERT INTO public.products (name, slug, category_id, price, mrp, description, main_image, is_featured, is_new_arrival, status)
  VALUES ('Egyptian Giza Cotton Premium Shirting Material', 'egyptian-giza-cotton-premium-shirting-material', cat_shirting, 799.00, 1299.00,
          'Authentic long-staple Egyptian Giza combed cotton. Ultra-smooth silky hand-feel with natural luster for high-end formal and semi-formal bespoke shirts.',
          base_img || '/1789297232704_cjkzc6_1000226233_webp.webp', true, true, 'published')
  ON CONFLICT (slug) DO UPDATE SET price = EXCLUDED.price, mrp = EXCLUDED.mrp
  RETURNING id INTO p_id;

  INSERT INTO public.product_variants (product_id, size, sku, stock_quantity)
  VALUES 
    (p_id, '1.2M', SUBSTRING(p_id::text, 1, 8) || '-12M', 30),
    (p_id, '1.6M', SUBSTRING(p_id::text, 1, 8) || '-16M', 30),
    (p_id, '2.0M', SUBSTRING(p_id::text, 1, 8) || '-20M', 25),
    (p_id, '2.5M', SUBSTRING(p_id::text, 1, 8) || '-25M', 20),
    (p_id, '3.0M', SUBSTRING(p_id::text, 1, 8) || '-30M', 15)
  ON CONFLICT (sku) DO NOTHING;

  -- 4. SHIRTING - Royal Classic Dobby Weave
  INSERT INTO public.products (name, slug, category_id, price, mrp, description, main_image, is_featured, is_new_arrival, status)
  VALUES ('Royal Classic Dobby Weave Shirting Fabric', 'royal-classic-dobby-weave-shirting-fabric', cat_shirting, 899.00, 1499.00,
          'Geometric micro-dobby structured cotton weave with breathable texture. Holds crisp collar and cuffs through long business days.',
          base_img || '/1789297233424_l6m9az_1000227473_webp.webp', true, true, 'published')
  ON CONFLICT (slug) DO UPDATE SET price = EXCLUDED.price, mrp = EXCLUDED.mrp
  RETURNING id INTO p_id;

  INSERT INTO public.product_variants (product_id, size, sku, stock_quantity)
  VALUES 
    (p_id, '1.2M', SUBSTRING(p_id::text, 1, 8) || '-12M', 30),
    (p_id, '1.6M', SUBSTRING(p_id::text, 1, 8) || '-16M', 30),
    (p_id, '2.0M', SUBSTRING(p_id::text, 1, 8) || '-20M', 25),
    (p_id, '2.5M', SUBSTRING(p_id::text, 1, 8) || '-25M', 20),
    (p_id, '3.0M', SUBSTRING(p_id::text, 1, 8) || '-30M', 15)
  ON CONFLICT (sku) DO NOTHING;

  -- 5. COTTON - Superfine 60s Count Pure Cotton
  INSERT INTO public.products (name, slug, category_id, price, mrp, description, main_image, is_featured, is_new_arrival, status)
  VALUES ('Superfine 60s Count Pure Cotton Cloth Material', 'superfine-60s-count-pure-cotton-cloth-material', cat_cotton, 599.00, 999.00,
          'Finely combed 60s count pure cotton material. Light, breathable, skin-friendly and ideal for daily custom shirts and traditional kurtas.',
          base_img || '/1789297234153_828a29_1000226242_webp.webp', true, true, 'published')
  ON CONFLICT (slug) DO UPDATE SET price = EXCLUDED.price, mrp = EXCLUDED.mrp
  RETURNING id INTO p_id;

  INSERT INTO public.product_variants (product_id, size, sku, stock_quantity)
  VALUES 
    (p_id, '1.2M', SUBSTRING(p_id::text, 1, 8) || '-12M', 30),
    (p_id, '1.6M', SUBSTRING(p_id::text, 1, 8) || '-16M', 30),
    (p_id, '2.0M', SUBSTRING(p_id::text, 1, 8) || '-20M', 25),
    (p_id, '2.5M', SUBSTRING(p_id::text, 1, 8) || '-25M', 20),
    (p_id, '3.0M', SUBSTRING(p_id::text, 1, 8) || '-30M', 15)
  ON CONFLICT (sku) DO NOTHING;

  -- 6. COTTON - Handloom Mercerized Cotton
  INSERT INTO public.products (name, slug, category_id, price, mrp, description, main_image, is_featured, is_new_arrival, status)
  VALUES ('Handloom Mercerized Cotton Festive Kurta Fabric', 'handloom-mercerized-cotton-festive-kurta-fabric', cat_cotton, 699.00, 1099.00,
          'Mercerized double-ply cotton handloom fabric with subtle sheen and high tensile strength. Perfect for festive celebrations and weddings.',
          base_img || '/1789297489218_jchzvp_1000227479_webp.webp', true, true, 'published')
  ON CONFLICT (slug) DO UPDATE SET price = EXCLUDED.price, mrp = EXCLUDED.mrp
  RETURNING id INTO p_id;

  INSERT INTO public.product_variants (product_id, size, sku, stock_quantity)
  VALUES 
    (p_id, '1.2M', SUBSTRING(p_id::text, 1, 8) || '-12M', 30),
    (p_id, '1.6M', SUBSTRING(p_id::text, 1, 8) || '-16M', 30),
    (p_id, '2.0M', SUBSTRING(p_id::text, 1, 8) || '-20M', 25),
    (p_id, '2.5M', SUBSTRING(p_id::text, 1, 8) || '-25M', 20),
    (p_id, '3.0M', SUBSTRING(p_id::text, 1, 8) || '-30M', 15)
  ON CONFLICT (sku) DO NOTHING;

  -- 7. LINEN - Pure 60 LEA European Flax Linen
  INSERT INTO public.products (name, slug, category_id, price, mrp, description, main_image, is_featured, is_new_arrival, status)
  VALUES ('Pure 60 LEA European Flax Linen Material', 'pure-60-lea-european-flax-linen-material', cat_linen, 1299.00, 1999.00,
          'Certified 100% pure European flax 60 LEA unstitched linen fabric. Naturally thermoregulating, exceptionally breathable and luxurious.',
          base_img || '/1789297490167_0g58yv_1000226235_webp.webp', true, true, 'published')
  ON CONFLICT (slug) DO UPDATE SET price = EXCLUDED.price, mrp = EXCLUDED.mrp
  RETURNING id INTO p_id;

  INSERT INTO public.product_variants (product_id, size, sku, stock_quantity)
  VALUES 
    (p_id, '1.2M', SUBSTRING(p_id::text, 1, 8) || '-12M', 30),
    (p_id, '1.6M', SUBSTRING(p_id::text, 1, 8) || '-16M', 30),
    (p_id, '2.0M', SUBSTRING(p_id::text, 1, 8) || '-20M', 25),
    (p_id, '2.5M', SUBSTRING(p_id::text, 1, 8) || '-25M', 20),
    (p_id, '3.0M', SUBSTRING(p_id::text, 1, 8) || '-30M', 15)
  ON CONFLICT (sku) DO NOTHING;

  -- 8. LINEN - Heritage Yarn-Dyed Textured Linen
  INSERT INTO public.products (name, slug, category_id, price, mrp, description, main_image, is_featured, is_new_arrival, status)
  VALUES ('Heritage Yarn-Dyed Textured Linen Fabric', 'heritage-yarn-dyed-textured-linen-fabric', cat_linen, 1399.00, 2199.00,
          'Distinctive yarn-dyed woven linen with subtle two-tone cross-weave. Tailors into relaxed luxury shirts, waistcoats, and summer trousers.',
          base_img || '/1789297619778_26gxmo_1000227488_webp.webp', true, true, 'published')
  ON CONFLICT (slug) DO UPDATE SET price = EXCLUDED.price, mrp = EXCLUDED.mrp
  RETURNING id INTO p_id;

  INSERT INTO public.product_variants (product_id, size, sku, stock_quantity)
  VALUES 
    (p_id, '1.2M', SUBSTRING(p_id::text, 1, 8) || '-12M', 30),
    (p_id, '1.6M', SUBSTRING(p_id::text, 1, 8) || '-16M', 30),
    (p_id, '2.0M', SUBSTRING(p_id::text, 1, 8) || '-20M', 25),
    (p_id, '2.5M', SUBSTRING(p_id::text, 1, 8) || '-25M', 20),
    (p_id, '3.0M', SUBSTRING(p_id::text, 1, 8) || '-30M', 15)
  ON CONFLICT (sku) DO NOTHING;

  -- 9. KHADI - Authentic Handspun Solar Khadi
  INSERT INTO public.products (name, slug, category_id, price, mrp, description, main_image, is_featured, is_new_arrival, status)
  VALUES ('Authentic Handspun Solar Khadi Cotton Material', 'authentic-handspun-solar-khadi-cotton-material', cat_khadi, 649.00, 1050.00,
          'Traditional Indian handspun and handwoven khadi cotton. Pure organic texture that breathes naturally, stays cool in summer and warm in winter.',
          base_img || '/1789297908135_a3cd8p_1000227490_webp.webp', true, true, 'published')
  ON CONFLICT (slug) DO UPDATE SET price = EXCLUDED.price, mrp = EXCLUDED.mrp
  RETURNING id INTO p_id;

  INSERT INTO public.product_variants (product_id, size, sku, stock_quantity)
  VALUES 
    (p_id, '1.2M', SUBSTRING(p_id::text, 1, 8) || '-12M', 30),
    (p_id, '1.6M', SUBSTRING(p_id::text, 1, 8) || '-16M', 30),
    (p_id, '2.0M', SUBSTRING(p_id::text, 1, 8) || '-20M', 25),
    (p_id, '2.5M', SUBSTRING(p_id::text, 1, 8) || '-25M', 20),
    (p_id, '3.0M', SUBSTRING(p_id::text, 1, 8) || '-30M', 15)
  ON CONFLICT (sku) DO NOTHING;

  -- 10. KHADI - Organic Slub Khadi Textured Kurta Cloth
  INSERT INTO public.products (name, slug, category_id, price, mrp, description, main_image, is_featured, is_new_arrival, status)
  VALUES ('Organic Slub Khadi Textured Kurta Cloth', 'organic-slub-khadi-textured-kurta-cloth', cat_khadi, 749.00, 1199.00,
          'Character-rich slub yarn handloom khadi fabric. Natural earthy tones with tactile luxury, crafted for bespoke kurtas and Nehru jackets.',
          base_img || '/1789297909463_c1g148_1000226238_webp.webp', true, true, 'published')
  ON CONFLICT (slug) DO UPDATE SET price = EXCLUDED.price, mrp = EXCLUDED.mrp
  RETURNING id INTO p_id;

  INSERT INTO public.product_variants (product_id, size, sku, stock_quantity)
  VALUES 
    (p_id, '1.2M', SUBSTRING(p_id::text, 1, 8) || '-12M', 30),
    (p_id, '1.6M', SUBSTRING(p_id::text, 1, 8) || '-16M', 30),
    (p_id, '2.0M', SUBSTRING(p_id::text, 1, 8) || '-20M', 25),
    (p_id, '2.5M', SUBSTRING(p_id::text, 1, 8) || '-25M', 20),
    (p_id, '3.0M', SUBSTRING(p_id::text, 1, 8) || '-30M', 15)
  ON CONFLICT (sku) DO NOTHING;

  -- 11. SILK - Royal Mulberry Raw Silk
  INSERT INTO public.products (name, slug, category_id, price, mrp, description, main_image, is_featured, is_new_arrival, status)
  VALUES ('Royal Mulberry Raw Silk Cloth Material', 'royal-mulberry-raw-silk-cloth-material', cat_silk, 1999.00, 3499.00,
          'Exquisite 100% pure raw mulberry silk unstitched fabric. Rich natural texture with royal golden undertones for heritage wedding kurtas and bandhgalas.',
          base_img || '/1789298754250_i2i93m_1000227495_webp.webp', true, true, 'published')
  ON CONFLICT (slug) DO UPDATE SET price = EXCLUDED.price, mrp = EXCLUDED.mrp
  RETURNING id INTO p_id;

  INSERT INTO public.product_variants (product_id, size, sku, stock_quantity)
  VALUES 
    (p_id, '1.2M', SUBSTRING(p_id::text, 1, 8) || '-12M', 30),
    (p_id, '1.6M', SUBSTRING(p_id::text, 1, 8) || '-16M', 30),
    (p_id, '2.0M', SUBSTRING(p_id::text, 1, 8) || '-20M', 25),
    (p_id, '2.5M', SUBSTRING(p_id::text, 1, 8) || '-25M', 20),
    (p_id, '3.0M', SUBSTRING(p_id::text, 1, 8) || '-30M', 15)
  ON CONFLICT (sku) DO NOTHING;

  -- 12. SILK - Regal Tussar Matka Silk
  INSERT INTO public.products (name, slug, category_id, price, mrp, description, main_image, is_featured, is_new_arrival, status)
  VALUES ('Regal Tussar Matka Silk Festive Fabric', 'regal-tussar-matka-silk-festive-fabric', cat_silk, 2299.00, 3999.00,
          'Heavyweight Tussar Matka wild silk fabric with authentic hand-reeled texture. Unmatched royal drape designed for bespoke ceremonial attires.',
          base_img || '/1789298755481_cf4zqh_1000227491_webp.webp', true, true, 'published')
  ON CONFLICT (slug) DO UPDATE SET price = EXCLUDED.price, mrp = EXCLUDED.mrp
  RETURNING id INTO p_id;

  INSERT INTO public.product_variants (product_id, size, sku, stock_quantity)
  VALUES 
    (p_id, '1.2M', SUBSTRING(p_id::text, 1, 8) || '-12M', 30),
    (p_id, '1.6M', SUBSTRING(p_id::text, 1, 8) || '-16M', 30),
    (p_id, '2.0M', SUBSTRING(p_id::text, 1, 8) || '-20M', 25),
    (p_id, '2.5M', SUBSTRING(p_id::text, 1, 8) || '-25M', 20),
    (p_id, '3.0M', SUBSTRING(p_id::text, 1, 8) || '-30M', 15)
  ON CONFLICT (sku) DO NOTHING;

END $$;
