-- Bucket público "products" y políticas RLS para subir imágenes desde el panel web.
-- Ejecutar manualmente en Supabase SQL Editor después de sql/01_admin_staff.sql.

INSERT INTO storage.buckets (id, name, public)
VALUES ('products', 'products', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Lectura pública de imágenes del catálogo (para la app Android y vista previa web).
DROP POLICY IF EXISTS "products_bucket_public_read" ON storage.objects;
CREATE POLICY "products_bucket_public_read" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'products');

-- Solo personal activo en admin_staff puede subir, actualizar o eliminar imágenes en "products".
DROP POLICY IF EXISTS "products_bucket_admin_insert" ON storage.objects;
CREATE POLICY "products_bucket_admin_insert" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'products'
  AND EXISTS (
    SELECT 1 FROM public.admin_staff s
    WHERE s.user_id = (SELECT auth.uid())
      AND s.active IS TRUE
      AND s.role IN ('owner', 'admin', 'staff', 'trainer')
  )
);

DROP POLICY IF EXISTS "products_bucket_admin_update" ON storage.objects;
CREATE POLICY "products_bucket_admin_update" ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'products'
  AND EXISTS (
    SELECT 1 FROM public.admin_staff s
    WHERE s.user_id = (SELECT auth.uid())
      AND s.active IS TRUE
      AND s.role IN ('owner', 'admin', 'staff', 'trainer')
  )
)
WITH CHECK (
  bucket_id = 'products'
  AND EXISTS (
    SELECT 1 FROM public.admin_staff s
    WHERE s.user_id = (SELECT auth.uid())
      AND s.active IS TRUE
      AND s.role IN ('owner', 'admin', 'staff', 'trainer')
  )
);

DROP POLICY IF EXISTS "products_bucket_admin_delete" ON storage.objects;
CREATE POLICY "products_bucket_admin_delete" ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'products'
  AND EXISTS (
    SELECT 1 FROM public.admin_staff s
    WHERE s.user_id = (SELECT auth.uid())
      AND s.active IS TRUE
      AND s.role IN ('owner', 'admin', 'staff', 'trainer')
  )
);

