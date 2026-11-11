# PRIMEGYM Admin Web

Panel administrativo React/Vite conectado a Supabase. Basado en los nombres de tablas **observados en el código Android** del ZIP PRIMEGYM: `profiles`, `products`, `services`, `group_classes`, `body_measurements`, `workout_sessions`, `set_logs` y `gym_attendance`.

> No se verificó el esquema real de PostgreSQL ni se ha accedido a datos de producción. Los módulos de membresías y pagos quedan marcados como pendientes; no se inventaron tablas. Los indicadores muestran errores/ausencia de datos explícitamente, sin números de muestra.

## Arrancar

Requiere Node.js 20+.

```bash
npm install
cp .env.example .env.local
```

Edita `.env.local` para usar tu **clave publishable** `sb_publishable_...` (la que ya tienes) y la URL `https://ygdojzogcwpxjsljdbjn.supabase.co`. En Windows puedes copiar el archivo manualmente o usar `copy .env.example .env.local`.

```bash
npm run dev
```

Abre la URL local indicada por Vite. Para compilar para despliegue: `npm run build`. El directorio `dist/` se puede publicar en un hosting estático HTTPS (Vercel, Netlify, Cloudflare Pages, etc.). Configura las variables de entorno en el hosting y, si corresponde, la URL autorizada de Auth en Supabase.

## Despliegue en Vercel

El proyecto incluye `vercel.json` (framework `vite`, salida `dist` y rewrites SPA) y `.vercelignore`.

1. Importa el repositorio en Vercel (o ejecuta `npx vercel --prod` desde esta carpeta).
2. En **Project Settings → Environment Variables**, agrega las variables de `.env.example`:
   - `VITE_SUPABASE_URL`: URL de tu proyecto Supabase (`https://ygdojzogcwpxjsljdbjn.supabase.co`).
   - `VITE_SUPABASE_PUBLISHABLE_KEY`: tu clave `sb_publishable_...` (nunca `service_role` ni `sb_secret_...`).
3. En Supabase (**Authentication → URL Configuration**), agrega tu dominio de Vercel (`https://tu-proyecto.vercel.app`) en **Site URL** y **Redirect URLs** si usas enlaces de confirmación o recuperación.

## Habilitar acceso administrativo

1. Crea/identifica una cuenta con contraseña en Supabase Authentication.
2. Revisa y ejecuta `sql/01_admin_staff.sql` en **SQL Editor** de Supabase. El script crea una única tabla adicional para identificar al personal administrativo, sin tocar las existentes.
3. En Supabase Auth copia el UUID de la cuenta. Ejecuta el INSERT comentado del SQL después de sustituir el UUID.
4. Configura **RLS real en cada tabla de negocio** para conceder a los roles pertinentes los permisos adecuados. El guard visual `admin_staff` NO sustituye RLS. Si las políticas no existen, la app mostrará errores/permisos insuficientes en lugar de desactivar seguridad.
5. Inicia sesión desde el panel usando el email y contraseña de esa cuenta.

## Seguridad imprescindible

- **Nunca** insertar `sb_secret_...`, `service_role`, contraseñas ni claves administrativas en `VITE_*`, React, el repositorio o archivos publicados; cualquier variable `VITE_*` es pública en el navegador.
- La clave secreta compartida anteriormente debe rotarse desde Supabase, y la antigua debe dejar de utilizarse.
- La clave publishable es pública y **no otorga acceso administrativo por sí misma**: Supabase Auth, RLS y/o Edge Functions deben proteger todas las operaciones.
- El panel ofrece edición de filas existentes si la tabla expone un campo `id`; para altas se habilitaron solo `products`, `services` y `group_classes` con campos iniciales aproximados, que debes adaptar al esquema **verificado**. Los errores de columnas faltantes se muestran tal cual.
- Para transacciones como membresías, pagos y reservas concurrentes, usar funciones de servidor y reglas transaccionales. No implementadas hasta conocer el modelo real.
- Para producción deshabilitar o restringir eliminación de registros que tengan dependencias. El botón de eliminación para productos/servicios/clases se muestra solo como función CRUD y respeta RLS.

## Qué está implementado

- Inicio de sesión real con Supabase Auth.
- Control de acceso al panel basado en tabla `admin_staff` con rol activo (la protección de datos depende además de RLS).
- Dashboard con conteos reales o indicadores de error; no hay datos falsos.
- Lectura paginada de ocho tablas observadas en Android.
- Búsqueda dentro de la página actual, estados de carga/error/vacío.
- Edición de campos de registros existentes con confirmación del servidor.
- Formularios básicos para productos, servicios y clases, sujetos a columnas y permisos reales.
- Diseño oscuro/dorado responsive, apto para móvil y escritorio.

## Pendiente para funcionamiento integral

- Verificar esquema real mediante exportación SQL / acceso de esquema de Supabase.
- Configurar permisos por roles y sucursales en todas las tablas.
- Diseñar y construir módulos de pagos, membresías, reservas, rutinas y entrenadores a partir de tablas auténticas.
- Validar constraints y tipos de datos de campos en los formularios.
- Integración de notificaciones, archivos, reportes financieros y métricas elaboradas.
- Pruebas con datos reales de un entorno de staging y auditoría de las políticas RLS.

Este proyecto no realiza migraciones de negocio ni modifica Android automáticamente.


## Catálogo Android ↔ panel web (diagnóstico de sincronización)

La aplicación Android consulta `public.products` usando `active=eq.true`. El panel tiene ahora una vista equivalente por defecto y un interruptor para incluir productos inactivos, si la sesión tiene permiso. El panel también diagnostica cuántos productos puede leer su cuenta, lo que NO demuestra el número total cuando RLS limita filas.

La tabla descrita en `PRIMEGYM/docs/primegym_supabase_schema.sql` exige `name`, `category` y `price`; el formulario web ahora incluye categoría, stock, moneda e imagen. **La moneda inicial MXN procede del SQL existente, no significa que sea la moneda correcta del negocio; ajústala desde configuración según tu país.**

Si el panel indica 0 y Android muestra productos: (1) compara la URL de Supabase de ambos proyectos; (2) confirma usando SQL Editor el total real de `public.products` y el total `active=true`; (3) examina las políticas RLS SELECT para el usuario del panel; (4) refresca Android con conexión de red y verifica que no son datos en caché; (5) no añadas productos duplicados ni desactives RLS para 'arreglar' el recuento.

Consulta `sql/02_products_diagnostics.sql` en SQL Editor (consulta de solo lectura). No pegues secretos en la aplicación web ni otorgues permisos de escritura a clientes Android.

### Imágenes de productos y catálogo inicial

- **Subida desde el panel web:** En el formulario de productos puedes pegar una URL HTTPS directa o subir un archivo (JPG, PNG, WEBP o GIF, máx. 5 MB) al bucket público `products` de Supabase Storage. Para habilitar ese bucket y restringir la subida únicamente al personal activo de `admin_staff`, ejecuta primero `sql/04_products_storage.sql` en SQL Editor.
- **Catálogo inicial con fotos reales:** Si deseas poblar productos de ejemplo con imágenes, ejecuta `sql/03_seed_primegym_catalog.sql` en SQL Editor.
