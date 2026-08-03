# FAQ

Preguntas frecuentes del proyecto y sus respuestas.

## ¿Cómo sé mi usuario y contraseña de Decap CMS?

Decap CMS **no tiene usuario/contraseña propios**. En **local** no se necesita nada (escribe al disco vía `decap-server`). En **producción** el login lo maneja **DecapBridge** (contraseña, Google o Microsoft) para los usuarios invitados.

## ¿Puedo tener ambos, backend local y GitHub?

Sí. Con `local_backend: true` en el mismo `config.yml`:

- En local, `decap-server` (proxy) escribe al filesystem local.
- En producción, sin proxy activo, se usa el backend remoto (DecapBridge).

## ¿Debo apagar `local_backend: true` en producción?

**No.** Si el proxy local no está corriendo (producción), Decap CMS cae automáticamente al backend remoto definido en `config.yml`. No hace falta modificar nada al desplegar.

## ¿Funciona Decap CMS en GitHub Pages?

Sí. El backend es `git-gateway` con **DecapBridge** (auth PKCE vía `auth.decapbridge.com`). No se depende de Netlify.

## ¿Necesito una cuenta de Netlify?

**No.** Netlify ya no participa. El login lo gestiona DecapBridge; el GitHub token vive solo en el servidor de DecapBridge.

## ¿Cómo se autentica Decap CMS en producción?

El proxy OAuth de Netlify que Decap usaba por defecto **ya no funciona** (el login da "not found"). Se usa **DecapBridge** (https://decapbridge.com): servicio de auth y gestión de usuarios para Decap CMS.

Setup (una sola vez):
1. Crear cuenta en https://decapbridge.com/auth/signup.
2. En el dashboard, "Add site": Git provider GitHub, repo `edgardo001/astrojs-blog-integration-cms-decapcms`, un **GitHub token** (fine-grained con permiso read/write a *Contents*; ver https://github.com/settings/tokens), la URL de login `https://astrojs-blog-integration-cms-decapcms.edgardovasquez.cl/admin/index.html` y el Auth type (Classic o PKCE para Google/Microsoft).
3. Copiar el `config.yml` generado y fusionarlo con el de `public/admin/config.yml` (conservando la colección `blog`).
4. Invitar colaboradores por email desde el dashboard.

El widget de Decap CMS está en `decap-cms@^3.15.1` (soporta PKCE/SSO).

## ¿Qué es `auth_endpoint` / `auth_token_endpoint`?

Son las URLs del flujo OAuth PKCE de DecapBridge:

- `base_url` + `auth_endpoint` → URL donde Decap **redirige al usuario para iniciar sesión** (la pantalla de login de DecapBridge).
- `auth_token_endpoint` → URL a la que Decap llama **después del login** para canjear el código temporal por un token de acceso.

Ambas incluyen el **UUID público del sitio** (como un `client_id`); no contienen secretos.

## ¿Debe ser público el repositorio?

**Sí**, para usar GitHub Pages gratuito el repo debe ser **público**. Con repo privado, además del costo de GitHub Pages, el CMS requeriría config adicional.

## ¿Cómo creo un nuevo post?

Dos opciones:

1. Desde el CMS: en producción entra a `/admin/`, inicia sesión con DecapBridge y crea el contenido. En local, levanta `start-dev.bat` y abre `/admin/` (sin login).
2. Directo en el repo: crea un archivo `src/content/blog/mi-post.md` siguiendo el frontmatter de `src/content.config.ts`.

## ¿Puedo publicar contenido distinto en varios blogs?

Sí. El sitio es **multi-blog**: además de `/blog` hay `blog_rrhh`, `blog_interno`, `blog_externo` y `blog_comunicados`, cada uno con su colección, su carpeta y sus rutas propias.

### ¿Cómo elijo a qué blog publicar en Decap CMS?

Cada blog es una **colección separada** en el sidebar de `/admin/` (Blog, Blog RRHH, Blog Interno, Blog Externo, Blog Comunicados):

1. Entra a `/admin/` y abre la colección del blog deseado.
2. Usa "Nueva entrada" para crear una publicación en esa colección.
3. Al guardar, Decap hace commit del `.md` a la carpeta de ese blog (`src/content/<blog>/`) y la página correspondiente (`/<blog>/`) lo muestra.

Los posts de cada blog no se mezclan: cada colección guarda en su propia carpeta y el frontend lee solo su content collection. Para agregar un blog nuevo basta añadir una colección en `public/admin/config.yml` (reusando `*campos_blog`), su collection en `src/content.config.ts` y su entrada en `src/data/blogs.ts`. Las rutas `[blog]` y el navbar se generan solos (no hay páginas por blog).

## ¿Cómo apago o enciendo un blog?

Hay dos formas posibles; hoy está implementada la primera:

### Opción 1 — Flag en tiempo de compilación (implementada)

Cada blog tiene un flag `enabled` en **`src/data/blogs.ts`**:

```ts
export const blogs: BlogInfo[] = [
  // ...
  { name: "blog_externo", label: "Blog Externo", /* ... */ enabled: true },
];
```

- Con `enabled: true` (o `false`) y un rebuild, el blog aparece o desaparece del sitio completo.
- Al apagarlo (`false`): se quita del **navbar**, deja de **generar sus rutas** (listado y posts) y desaparece del **sitemap** (el hosting responde 404 si alguien entra a la URL vieja).
- Requiere **tocar código** y **recompilar** (el deploy de GitHub Actions se encarga automáticamente con cada push a `main`).

### Opción 2 — Toggle editable desde Decap CMS (futura, no implementada)

Si se quiere que un editor encienda/apague blogs **sin tocar código**, se podría:

1. Crear una **colección de configuración** en `public/admin/config.yml` (una sola entrada, p. ej. `site-settings`) que guarde un archivo `.json`/`.md` al repo con la lista de blogs y sus `enabled`.
2. En el build, leer ese archivo (p. ej. `getCollection` sobre esa colección o `fs.readFile` desde `src/`) en vez de `blogs.ts`, y filtrar navbar + rutas con esos valores.
3. Cuando el editor cambie el toggle en `/admin/`, Decap hace commit del archivo → GitHub Actions reconstruye → el blog aparece/desaparece.

No está implementada porque agrega una colección extra y lógica de lectura en build; el flag de código es más simple y suficiente para el ejemplo.

## ¿Cómo llegan los posts a `src/content/blog` al compilar Astro?

Astro no consulta al CMS en compilación: lee los `.md` que ya existen en `src/content/blog/` mediante el loader `glob()` de `src/content.config.ts`. Quien los escribe ahí es Decap CMS haciendo un **commit directo al repositorio**:

1. El editor escribe/edita un post en `/admin/`.
2. Decap hace commit del archivo al repo (`src/content/blog/mi-post.md`).
3. El commit dispara el rebuild de GitHub Actions → `astro build` lee el `.md` y genera el HTML.

En local, el proxy `decap-server` escribe el `.md` directo en el disco y el dev server lo detecta al instante.

## ¿El puerto 8081 está ocupado por otro proceso? ¿Qué hago?

`8081` lo usa el proxy local de Decap CMS (`decap-server`). Si otro programa lo ocupa (p. ej. Docker), `decap-server` no puede arrancar y Decap CMS en `/admin/` cae al backend remoto de DecapBridge → **pide login de GitHub en local**.

`start-dev.bat` valida el puerto **antes** de iniciar nada:

- Si 8081 está ocupado → muestra el proceso/PID que lo usa, avisa que `/admin/` pediría login y **aborta sin iniciar Astro** (exit code 1). **No mata nada automáticamente.**
- Si 8081 está libre → arranca `decap-server`, espera (con reintentos, hasta 10 s) a que escuche y recién entonces ejecuta `npm run dev`. Al salir detiene el proxy.

Para ver quién ocupa el puerto y liberarlo, ejecuta **`kill-dev.bat`**: lista el/los proceso(s) con su línea de comandos y pregunta antes de matar (responde `S` para terminar, `N` para no tocar nada). Acepta otro puerto como argumento: `kill-dev.bat 8082`.

Opciones si no quieres liberar el puerto:

1. **Solo ver el sitio** (sin CMS): ejecuta `npm run dev` manualmente.
2. **Usar el CMS local**: detén el proceso que ocupa 8081 (con `kill-dev.bat`) o configura `decap-server` en otro puerto (`PORT=8082 npx decap-server`) y apunta `local_backend.url` en `config.yml` a ese puerto.

## ¿Qué pasa si cierro la ventana de `start-dev.bat`?

El dev server de Astro se detiene con la ventana, pero el proxy `decap-server` puede **quedar huérfano** en 8081 (a veces no muere con la consola). No es un problema: ejecuta **`kill-dev.bat`** para ver qué quedó y liberar el puerto antes de volver a iniciar. También puedes liberarlo a mano:

```powershell
Get-NetTCPConnection -LocalPort 8081 -State Listen
Stop-Process -Id <PID>
```

## ¿Cómo despliego y publico cambios?

1. El repo debe ser **público** y en Settings → Pages elegir "GitHub Actions" como source.
2. El workflow `.github/workflows/deploy.yml` construye y publica el sitio en cada push a `main` (incluidos los commits del CMS).
3. `site` en `astro.config.mjs` = `https://astrojs-blog-integration-cms-decapcms.edgardovasquez.cl` (sin `base`, se sirve en la raíz del subdominio).

## ¿Cómo sabe GitHub cuál es mi dominio?

Porque se lo configuras tú: en **Settings → Pages → Custom domain** guardas el dominio, y el **DNS** del dominio apunta a GitHub Pages (un CNAME hacia `edgardo001.github.io`). GitHub verifica el registro y emite el certificado HTTPS. El dominio `edgardovasquez.cl` está configurado en el *user site* `edgardo001.github.io`, y de ahí sale la redirección `github.io` → `edgardovasquez.cl`.

## ¿En qué URL vive el sitio?

En el subdominio **`https://astrojs-blog-integration-cms-decapcms.edgardovasquez.cl`** (raíz, sin subcarpeta). El DNS está en Cloudflare:

- Registro **CNAME**: nombre `astrojs-blog-integration-cms-decapcms` → destino `edgardo001.github.io`, con proxy **DNS-only** (nube gris).
- Una vez el DNS resuelva, GitHub verifica el dominio y habilita HTTPS automáticamente.

## ¿Por qué GitGuardian me alerta por `auth_endpoint` / `auth_token_endpoint`?

Es un **falso positivo**. GitGuardian marca el UUID de DecapBridge (`b02f9cba-...`) como posible secreto, pero es solo el **identificador público** del sitio (como un `client_id` de OAuth), necesario y visible en el `config.yml`. El secreto real (GitHub token) vive solo en el servidor de DecapBridge.

Para que GitGuardian deje de alertar: **descartar (dismiss)** los incidentes como falso positivo en el dashboard. Los `.jpg` y la clave `id-token` del workflow también son falsos positivos.
