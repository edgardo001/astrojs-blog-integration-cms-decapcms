# MEMORY.md

Registro persistente del contexto, decisiones y bitácora del proyecto. Incluye el historial de lo que hacemos y el conocimiento adquirido, para consultarlo en el futuro.

## Objetivo del proyecto

Landing page de inicio con navbar y blog, construida con **AstroJS 7** y administrada con **Decap CMS**. Responsiva en móvil y desktop. Prioridad: el **blog y la integración con Decap CMS**; la landing es solo un inicio básico.

## Stack

- **Framework**: AstroJS 7.1.6 (https://astro.build)
- **CMS**: Decap CMS (https://github.com/decaporg/decap-cms) — widget vía CDN (`decap-cms@^3.15.1`, soporta PKCE/SSO)
- **Auth en producción**: DecapBridge (https://decapbridge.com) — sustituye al proxy OAuth de Netlify (deprecado)
- **Contenido**: Content Collections de Astro (Markdown)
- **Estilos**: CSS global en `src/styles/global.css` (sin Tailwind, vanilla + scoped en componentes)
- **Hosting**: GitHub Pages en subdominio `astrojs-blog-integration-cms-decapcms.edgardovasquez.cl` (DNS en Cloudflare)

## Decisiones de arquitectura

- El blog usa **Content Collections** de Astro 7 con el loader `glob()` definido en `src/content.config.ts` (schema con Zod desde `astro/zod`). Los posts viven en `src/content/blog/*.md`.
- **Decap CMS** se monta en `/admin/` (ruta `src/pages/admin.html` + `public/admin/config.yml`), y sus entradas se guardan como Markdown en `src/content/blog/`, consumible por Astro sin transformaciones.
- El CMS usa **`local_backend: true`**: en local escribe directo al filesystem vía proxy `decap-server`; en producción cae automáticamente al backend remoto (**DecapBridge**: `git-gateway` + PKCE). **No hay que apagar `local_backend` en producción.**
- **Auth**: DecapBridge maneja el login (contraseña, Google, Microsoft) y los commits los firma el autor (ver `commit_messages` en el config). No se necesita cuenta de Netlify.
- Las imágenes del CMS se guardan en `public/uploads/` (`media_folder: public/uploads`, `public_folder: /uploads`).
- Frontmatter mínimo por post: `title`, `description`, `pubDate`, `author`, `image`, `tags` (validado en `src/content.config.ts`).
- Navbar sticky responsivo (mobile-first) con menú hamburguesa mediante script vanilla.
- `start-dev.bat` es la **única fuente de inicio en desarrollo**: lanza el proxy `decap-server` con `start /b` (misma consola) y luego `npm run dev`. Cerrar la ventana apaga todo.
- `site` en `astro.config.mjs` = subdominio; **sin `base`** (se sirve en la raíz del custom domain). Las rutas internas usan `import.meta.env.BASE_URL` (funciona con o sin base).

## Estado actual

- [x] Documentación base (README, .gitignore, MEMORY, AGENTS, FAQ)
- [x] Proyecto Astro 7.1.6 con TypeScript strict
- [x] Landing page con navbar/footer responsivo + 404
- [x] Blog (listado + `[slug]`) con posts de muestra e imágenes reales (3 por post)
- [x] SEO social: Open Graph + Twitter Cards con `og:image` absoluta
- [x] Integración Decap CMS (`/admin` + `config.yml` + `local_backend`) con **DecapBridge** (PKCE)
- [x] Proxy local `decap-server` (devDependency)
- [x] Workflow `.github/workflows/deploy.yml` (rebuild en cada push a `main`, incluye commits del CMS)
- [x] Custom domain `astrojs-blog-integration-cms-decapcms.edgardovasquez.cl` + `build_type: workflow` en GitHub
- [x] DNS en Cloudflare (CNAME del subdominio → `edgardo001.github.io`) — **sitio funcionando en el subdominio**
- [x] `backend.repo` = `edgardo001/astrojs-blog-integration-cms-decapcms`
- [x] Desplegado en GitHub Pages (repo público `edgardo001/astrojs-blog-integration-cms-decapcms`)
- [ ] Probar flujo completo: login DecapBridge → crear post → commit → rebuild automático

## Conocimiento clave (lecciones aprendidas)

- **Astro 7**: Content Collections se definen en `src/content.config.ts` (no `src/content/config.ts`) con `defineCollection` + loader `glob()` (`astro/loaders`) y `z` (`astro/zod`). El procesador Markdown por defecto es **Sätteri** (ya no trae `unified`; para `rehypePlugins` haría falta `@astrojs/markdown-remark` — se probó y se quitó, no hizo falta con raíz).
- **GitHub Pages + dominios**: el custom domain vive en los Settings del repo/user site, no necesariamente en un archivo `CNAME`. `github.io` redirige al custom domain. Un *project site* con custom domain propio se sirve en la **raíz** del dominio (por eso `site` = subdominio y sin `base`). Desde Actions se usa `build_type: workflow` (el build legacy falla con Astro: ruido normal).
- **Decap CMS**: el proxy OAuth de Netlify por defecto está **descontinuado** (login "not found"); se usa **DecapBridge** (PKCE). `local_backend: true` + `decap-server` = CMS local sin login; en producción cae solo al backend remoto. GitGuardian marca el UUID de DecapBridge como falso positivo.
- **Herramientas**: `start-dev.bat` usa `start /b` (misma consola → cerrar apaga todo). El workflow reconstruye con cada push a `main` (incluidos commits del CMS).
- El detalle de cada punto está en **FAQ.md** (preguntas/respuestas) y en la bitácora de este archivo.

## Bitácora (historial cronológico)

### 2026-08-02 — Setup del proyecto
1. Se crearon `README.md`, `.gitignore`, `MEMORY.md`, `AGENTS.md`.
2. Se confirmó que Astro está en la **v7.1** (astro.build).
3. Se decidió priorizar el **blog + Decap CMS**; la landing es básica.
4. Se creó `start-dev.bat`.
5. Se inicializó el proyecto con `npm create astro@latest --template minimal --typescript strict --no-git --install`.
   - npm pasó `--typescript` como nombre de carpeta; se movieron los archivos a la raíz y se eliminó la subcarpeta sobrante.
   - Se corrigió `package.json` (name era `--typescript`) y se agregó el script `check` (`astro check`) + `@astrojs/check` y `typescript` como devDeps.
6. Se crearon: `global.css`, `Layout.astro`, `Navbar.astro` (hamburguesa), `Footer.astro`, landing (`index.astro`), `404.astro`.
7. Content collection `blog` en `src/content.config.ts` + 2 posts de ejemplo.
8. Rutas del blog: listado en `src/pages/blog/index.astro` y post individual en `src/pages/blog/[slug].astro`.
9. Integración Decap CMS: `src/pages/admin.html` (CDN) y `public/admin/config.yml` (colección `blog` con campos en español).
10. Verificación: `npm run check` → 0 errores/warnings; `npm run build` → 6 páginas; smoke test del dev server → rutas 200.

### 2026-08-02 — Autenticación de Decap CMS
1. Se explicó que Decap CMS **no usa usuario/contraseña propios**.
2. Se agregó `local_backend: true` para local **y** GitHub a la vez.
3. Se instaló `decap-server` como devDependency (proxy en puerto 8081).
4. Se creó `FAQ.md`.

### 2026-08-02 — Decisión de despliegue: GitHub Pages
1. El usuario confirmó despliegue en **GitHub Pages** (no Netlify).
2. Se cambió el backend de `git-gateway` a `github` con placeholder.
3. Se eliminó `start-cms.bat`; `start-dev.bat` quedó como única fuente de inicio.
4. `start-dev.bat` usa `start /b` (misma consola → cerrar apaga todo).

### 2026-08-02 — GitHub Pages: workflow y documentación
1. Se creó `.github/workflows/deploy.yml` (checkout → node 22 → `npm ci` → `npm run build` → upload artifact → deploy-pages). Se dispara en cada push a `main` y con `workflow_dispatch`.
2. Se documentó en README y FAQ el flujo de despliegue.

### 2026-08-02 — SEO social y posts con imágenes reales
1. Los posts de muestra usan **fotos reales** (3 por post: portada + medio + final) en `public/uploads/`.
2. Se agregaron **Open Graph** y **Twitter Cards** en `Layout.astro` (`og:image` absoluta desde `Astro.site` + `image` del frontmatter).

### 2026-08-02 — Subdominio personalizado + Cloudflare
1. El sitio se sirve en **`https://astrojs-blog-integration-cms-decapcms.edgardovasquez.cl`** (raíz).
2. `astro.config.mjs`: `site` = subdominio, sin `base`. Rutas con `import.meta.env.BASE_URL`.
3. Se eliminó el plugin rehype de prefijo y `@astrojs/markdown-remark` (innecesarios con raíz).
4. En GitHub (API): custom domain del project site + `build_type: workflow`.
5. DNS en Cloudflare: CNAME `astrojs-blog-integration-cms-decapcms` → `edgardo001.github.io`.

### 2026-08-02 — Login de Decap CMS y repo real
1. El login de Decap a `api.netlify.com` daba **"not found"**: proxy OAuth de Netlify **descontinuado**.
2. Decisión: usar **DecapBridge** para auth en producción.
3. Se corrigió `backend.repo` → `edgardo001/astrojs-blog-integration-cms-decapcms`.
4. Widget de Decap CMS a `decap-cms@^3.15.1`.

### 2026-08-02 — Integración DecapBridge y alertas de GitGuardian
1. Se fusionó el `config.yml` de DecapBridge (git-gateway + PKCE, `auth_endpoint`/`auth_token_endpoint` con UUID público, `gateway_url`, commit messages, claims, `site_url`), conservando `local_backend`, `locale`, `media_folder` y la colección `blog`.
2. GitGuardian alerta por el **UUID de DecapBridge**, binarios `.jpg` y `id-token`: **todos falsos positivos**.
3. Se documentó en FAQ la resolución del login y los falsos positivos.

## Convenciones

- Textos de UI en **español**.
- Sin comentarios de código salvo que se pidan.
- Rutas de páginas: `index`, `blog`, `blog/[slug]`, `404`, `admin`.
- Verificación obligatoria: `npm run check` y `npm run build` después de cambios.
- Git: commits atómicos con Conventional Commits en inglés (ver AGENTS.md).

## Enlaces de referencia

- Astro: https://astro.build | Docs content collections: https://docs.astro.build/en/guides/content-collections/
- Decap CMS: https://github.com/decaporg/decap-cms | Docs: https://decapcms.org/docs/
- Guía oficial Astro + Decap CMS: https://docs.astro.build/en/guides/cms/decap-cms/
- Proxy local: https://decapcms.org/docs/working-with-a-local-git-repository/
- DecapBridge: https://decapbridge.com | Docs: https://decapbridge.com/docs/getting-started
- OAuth providers externos (si algún día se deja DecapBridge): https://decapcms.org/docs/external-oauth-clients/
