-- Diagnóstico solo lectura: ejecutar en Supabase SQL Editor del proyecto correcto.
SELECT current_database() AS db, current_schema() AS schema_name;
SELECT count(*) AS total,
       count(*) FILTER (WHERE active IS TRUE) AS activos,
       count(*) FILTER (WHERE active IS FALSE) AS inactivos
FROM public.products;
SELECT id, name, category, price, currency, stock, active, image_url
FROM public.products ORDER BY name LIMIT 30;
SELECT policyname, roles, cmd, qual, with_check
FROM pg_policies WHERE schemaname='public' AND tablename='products';
-- Compara esos resultados con el diagnóstico visible del panel.
-- Si SQL Editor muestra datos pero el panel no, revisar RLS del usuario web.
-- No desactivar RLS ni añadir políticas permisivas globales para resolver el error.
