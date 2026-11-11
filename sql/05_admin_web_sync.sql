-- ============================================================================
-- PRIMEGYM & GANIKUS GYM: SINCRONIZACIÓN WEB ADMIN Y APP ANDROID
-- ============================================================================
-- Ejecutar en Supabase SQL Editor:
-- https://supabase.com/dashboard/project/ygdojzogcwpxjsljdbjn/sql
-- ============================================================================

-- 1. TABLA DE CONFIGURACIÓN DE SEDE Y GIMNASIO (MODIFICABLE DESDE LA WEB)
CREATE TABLE IF NOT EXISTS public.gym_settings (
  id TEXT PRIMARY KEY DEFAULT 'default',
  gym_name TEXT NOT NULL DEFAULT 'Ganikus Gym',
  address TEXT NOT NULL DEFAULT 'Floridablanca / Bucaramanga, Santander, Colombia',
  latitude NUMERIC(10,7) NOT NULL DEFAULT 7.1076591,
  longitude NUMERIC(10,7) NOT NULL DEFAULT -73.1189395,
  google_maps_url TEXT NOT NULL DEFAULT 'https://www.google.com/maps/place/Ganikus+gym/@7.1070282,-73.1222719,17z/data=!4m6!3m5!1s0x8e683f64f010ef4d:0xd8ef023148a66ca3!8m2!3d7.1076591!4d-73.1189395!16s%2Fg%2F11nhgz90by',
  hours_weekday TEXT NOT NULL DEFAULT '5:00 AM – 10:00 PM',
  hours_saturday TEXT NOT NULL DEFAULT '6:00 AM – 8:00 PM',
  hours_sunday TEXT NOT NULL DEFAULT '7:00 AM – 2:00 PM',
  phone_contact TEXT DEFAULT '+57 300 000 0000',
  announcement TEXT DEFAULT '¡Bienvenidos a Ganikus Gym! Entrena al máximo nivel.',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Seed oficial con Ganikus Gym
INSERT INTO public.gym_settings (
  id, gym_name, address, latitude, longitude, google_maps_url,
  hours_weekday, hours_saturday, hours_sunday, phone_contact, announcement
)
VALUES (
  'default',
  'Ganikus Gym',
  'Floridablanca / Bucaramanga, Santander, Colombia',
  7.1076591,
  -73.1189395,
  'https://www.google.com/maps/place/Ganikus+gym/@7.1070282,-73.1222719,17z/data=!4m6!3m5!1s0x8e683f64f010ef4d:0xd8ef023148a66ca3!8m2!3d7.1076591!4d-73.1189395!16s%2Fg%2F11nhgz90by',
  '5:00 AM – 10:00 PM',
  '6:00 AM – 8:00 PM',
  '7:00 AM – 2:00 PM',
  '+57 300 000 0000',
  '¡Bienvenidos a Ganikus Gym! Tu mejor versión empieza hoy.'
)
ON CONFLICT (id) DO UPDATE SET
  gym_name = EXCLUDED.gym_name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  google_maps_url = EXCLUDED.google_maps_url;

ALTER TABLE public.gym_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read gym settings" ON public.gym_settings;
CREATE POLICY "Anyone can read gym settings" ON public.gym_settings
  FOR SELECT TO anon, authenticated USING (true);


-- 2. FUNCIÓN DE SEGURIDAD PARA VERIFICAR PERSONAL ADMINISTRATIVO
CREATE OR REPLACE FUNCTION public.is_admin_staff()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_staff
    WHERE user_id = auth.uid() AND active = true
  );
$$;

DROP POLICY IF EXISTS "Staff can update gym settings" ON public.gym_settings;
CREATE POLICY "Staff can update gym settings" ON public.gym_settings
  FOR ALL TO authenticated USING (public.is_admin_staff()) WITH CHECK (public.is_admin_staff());


-- 3. POLÍTICAS RLS PARA PERMITIR A LOS ADMINISTRADORES GESTIONAR LA APP
-- Productos: Lectura para todos, gestión total para administradores
DROP POLICY IF EXISTS "Public read products" ON public.products;
CREATE POLICY "Public read products" ON public.products
  FOR SELECT USING (active = true OR public.is_admin_staff());

DROP POLICY IF EXISTS "Staff can manage products" ON public.products;
CREATE POLICY "Staff can manage products" ON public.products
  FOR ALL TO authenticated USING (public.is_admin_staff()) WITH CHECK (public.is_admin_staff());

-- Servicios: Lectura para todos, gestión total para administradores
DROP POLICY IF EXISTS "Public read services" ON public.services;
CREATE POLICY "Public read services" ON public.services
  FOR SELECT USING (active = true OR public.is_admin_staff());

DROP POLICY IF EXISTS "Staff can manage services" ON public.services;
CREATE POLICY "Staff can manage services" ON public.services
  FOR ALL TO authenticated USING (public.is_admin_staff()) WITH CHECK (public.is_admin_staff());

-- Clases grupales: Lectura para todos, gestión total para administradores
DROP POLICY IF EXISTS "Public read group classes" ON public.group_classes;
CREATE POLICY "Public read group classes" ON public.group_classes
  FOR SELECT USING (active = true OR public.is_admin_staff());

DROP POLICY IF EXISTS "Staff can manage group classes" ON public.group_classes;
CREATE POLICY "Staff can manage group classes" ON public.group_classes
  FOR ALL TO authenticated USING (public.is_admin_staff()) WITH CHECK (public.is_admin_staff());

-- Membresías: Los socios leen las suyas, el staff gestiona todas
DROP POLICY IF EXISTS "Staff can manage memberships" ON public.memberships;
CREATE POLICY "Staff can manage memberships" ON public.memberships
  FOR ALL TO authenticated USING (public.is_admin_staff()) WITH CHECK (public.is_admin_staff());

-- Pagos: El staff puede consultar el historial de pagos
DROP POLICY IF EXISTS "Staff can view all payments" ON public.payments;
CREATE POLICY "Staff can view all payments" ON public.payments
  FOR SELECT TO authenticated USING (public.is_admin_staff());


-- 4. POBLAR PRODUCTOS SI LA TABLA ESTÁ VACÍA (Para que aparezcan de inmediato en la Web y la App)
INSERT INTO public.products (name, description, category, price, currency, stock, image_url, active, is_new_arrival)
SELECT 'Bebida Isotónica Elite 500ml', 'Fórmula con electrolitos, magnesio y sodio para rehidratación rápida durante entrenamientos intensos.', 'BEBIDAS', 3.50, 'USD', 60, 'https://images.unsplash.com/photo-1622543925917-763c34d1a86e?w=600&auto=format&fit=crop&q=80', true, false
WHERE NOT EXISTS (SELECT 1 FROM public.products LIMIT 1);

INSERT INTO public.products (name, description, category, price, currency, stock, image_url, active, is_new_arrival)
SELECT 'Pre-Workout Igniter 30 Servings', 'Energía extrema y enfoque mental con beta-alanina, cafeína anhidra y citrulina malato.', 'BEBIDAS', 34.99, 'USD', 30, 'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=600&auto=format&fit=crop&q=80', true, true
WHERE (SELECT count(*) FROM public.products) < 2;

INSERT INTO public.products (name, description, category, price, currency, stock, image_url, active, is_new_arrival)
SELECT 'Whey Isolate Protein 2lb (Chocolate)', 'Proteína 100% aislada de suero de leche, 27g de proteína pura por servicio, 0g azúcar.', 'NUTRICIÓN', 49.99, 'USD', 40, 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=600&auto=format&fit=crop&q=80', true, true
WHERE (SELECT count(*) FROM public.products) < 3;

INSERT INTO public.products (name, description, category, price, currency, stock, image_url, active, is_new_arrival)
SELECT 'Creatina Monohidratada Creapure 300g', 'Creatina micronizada pura grado farmacéutico para incremento de fuerza máxima y potencia.', 'SUPLEMENTOS', 28.50, 'USD', 50, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80', true, false
WHERE (SELECT count(*) FROM public.products) < 4;

INSERT INTO public.products (name, description, category, price, currency, stock, image_url, active, is_new_arrival)
SELECT 'Shaker Metálico Prime Gym 700ml', 'Vaso mezclador de acero inoxidable quirúrgico libre de BPA con rejilla antigrumos.', 'ACCESORIOS', 18.00, 'USD', 75, 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=600&auto=format&fit=crop&q=80', true, false
WHERE (SELECT count(*) FROM public.products) < 5;

-- 5. POBLAR SERVICIOS SI ESTÁ VACÍO
INSERT INTO public.services (name, description, category, price, currency, duration_minutes, active, is_featured, action_text)
SELECT 'Evaluación Antropométrica InBody', 'Medición detallada de composición corporal, porcentaje de grasa, masa muscular y agua corporal.', 'EVALUACIÓN', 25.00, 'USD', 45, true, true, 'Agendar cita'
WHERE NOT EXISTS (SELECT 1 FROM public.services LIMIT 1);

INSERT INTO public.services (name, description, category, price, currency, duration_minutes, active, is_featured, action_text)
SELECT 'Plan Nutricional Deportivo Personalizado', 'Diseño de plan alimenticio según requerimientos calóricos, entrenamientos y metas de masa o definición.', 'NUTRICIÓN', 45.00, 'USD', 60, true, true, 'Consultar plan'
WHERE (SELECT count(*) FROM public.services) < 2;

INSERT INTO public.services (name, description, category, price, currency, duration_minutes, active, is_featured, action_text)
SELECT 'Sesión de Fisioterapia y Descarga Muscular', 'Tratamiento miofascial, estiramientos asistidos y recuperación muscular con pistola de percusión.', 'RECUPERACIÓN', 35.00, 'USD', 50, true, false, 'Agendar sesión'
WHERE (SELECT count(*) FROM public.services) < 3;
