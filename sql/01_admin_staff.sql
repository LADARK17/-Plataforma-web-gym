-- Ejecutar manualmente en SQL Editor después de revisar la política de acceso.
-- Esta migración agrega SOLO la tabla de autorización de personal web.
-- No modifica las tablas existentes de PRIMEGYM.
CREATE TABLE IF NOT EXISTS public.admin_staff (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('owner','admin','staff','trainer')),
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.admin_staff ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "staff_can_read_own_role" ON public.admin_staff;
CREATE POLICY "staff_can_read_own_role" ON public.admin_staff
FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
-- PASO MANUAL: Localiza el UUID de tu usuario administrador creado en Supabase Auth.
-- Después de sustituir el UUID, ejecutar SOLO en SQL Editor (nunca en Android/web):
-- INSERT INTO public.admin_staff(user_id, role, active)
-- VALUES ('REEMPLAZA-CON-UUID-REAL', 'owner', true)
-- ON CONFLICT(user_id) DO UPDATE SET role='owner', active=true;
-- IMPORTANTE: Esto controla el acceso visual al panel. Cada tabla de negocio
-- NECESITA además sus políticas RLS de lectura/escritura para administradores.
-- No se configuran automáticamente porque requieren revisar tu esquema real.
