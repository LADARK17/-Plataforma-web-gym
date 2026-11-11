-- Catálogo inicial de productos PRIMEGYM con imágenes reales (Unsplash).
-- Ejecutar manualmente en Supabase SQL Editor.
INSERT INTO public.products (name, description, category, price, currency, stock, image_url, active, is_new_arrival)
VALUES
  (
    'Bebida Isotónica Elite 500ml',
    'Fórmula con electrolitos, magnesio y sodio para rehidratación rápida durante entrenamientos intensos.',
    'BEBIDAS',
    3.50,
    'USD',
    60,
    'https://images.unsplash.com/photo-1622543925917-763c34d1a86e?w=600&auto=format&fit=crop&q=80',
    true,
    false
  ),
  (
    'Pre-Workout Igniter 30 Servings',
    'Energía extrema y enfoque mental con beta-alanina, cafeína anhidra y citrulina malato.',
    'BEBIDAS',
    34.99,
    'USD',
    30,
    'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=600&auto=format&fit=crop&q=80',
    true,
    true
  ),
  (
    'Whey Isolate Protein 2lb (Chocolate Suizo)',
    'Proteína 100% aislada de suero de leche, 27g de proteína pura por servicio, 0g azúcar, baja en carbohidratos.',
    'NUTRICIÓN',
    49.99,
    'USD',
    40,
    'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=600&auto=format&fit=crop&q=80',
    true,
    true
  ),
  (
    'Creatina Monohidratada Creapure 300g',
    'Creatina micronizada pura grado farmacéutico para incremento de fuerza máxima y recuperación muscular.',
    'NUTRICIÓN',
    29.50,
    'USD',
    50,
    'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600&auto=format&fit=crop&q=80',
    true,
    false
  ),
  (
    'Barra de Proteína Crunch (Caja x 12)',
    '20g de proteína de suero, textura crocante sabor peanut butter y chocolate sin azúcares añadidos.',
    'SNACKS',
    24.00,
    'USD',
    25,
    'https://images.unsplash.com/photo-1622484212850-cab36b9e4a36?w=600&auto=format&fit=crop&q=80',
    true,
    false
  ),
  (
    'Camiseta Oversize PRIME Gold Edition',
    'Algodón pesado peinado de 240g con serigrafía dorada de alta resistencia para entrenamientos pesados.',
    'ROPA',
    28.00,
    'USD',
    35,
    'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=600&auto=format&fit=crop&q=80',
    true,
    true
  ),
  (
    'Shaker Botella PRIME 700ml Acero Inoxidable',
    'Vaso mezclador térmico libre de BPA, rejilla anti-grumos y tapa hermética antifugas.',
    'ACCESORIOS',
    18.00,
    'USD',
    40,
    'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=600&auto=format&fit=crop&q=80',
    true,
    true
  )
ON CONFLICT DO NOTHING;

