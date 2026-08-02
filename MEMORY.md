# MEMORY.md

Registro persistente del contexto, decisiones y bitácora del proyecto. Incluye el historial de lo que hacemos, preguntas del usuario y respuestas, para consultarlo en el futuro.

## Objetivo del proyecto

Landing page de inicio con navbar y blog, construida con **AstroJS 7** y administrada con **Decap CMS**. Responsiva en móvil y desktop. Prioridad: el **blog y la integración con Decap CMS**; la landing es solo un inicio básico.

## Stack

- **Framework**: AstroJS 7.1.6 (https://astro.build)
- **CMS**: Decap CMS (https://github.com/decaporg/decap-cms) — widget vía CDN (`decap-cms@^3.1.2`)
- **Contenido**: Content Collections de Astro (Markdown)
- **Estilos**: CSS global en `src/styles/global.css` (sin Tailwind, vanilla + scoped en componentes)

## Decisiones de arquitectura

- El blog usa **Content Collections** de Astro 7 con el loader `glob()` definido en `src/content.config.ts` (schema con Zod desde `astro/zod`). Los posts viven en `src/content/blog/*.md`.
- **Decap CMS** se monta en `/admin/` (ruta `src/pages/admin.html` + `public/admin/config.yml`), y sus entradas se guardan como Markdown en `src/content/blog/`, consumible por Astro sin transformaciones.
- El CMS usa **`local_backend: true`**: en local escribe directo al filesystem vía proxy `decap-server`; en producción cae automáticamente al backend remoto (`git-gateway`/GitHub). **No hay que apagar `local_backend` en producción.**
- Las imágenes del CMS se guardan en `public/uploads/` (`media_folder: public/uploads`, `public_folder: /uploads`).
- Frontmatter mínimo por post: `title`, `description`, `pubDate`, `author`, `image`, `tags` (validado en `src/content.config.ts`).
- Navbar sticky responsivo (mobile-first) con menú hamburguesa mediante script vanilla.
- `start-dev.bat` es la **única fuente de inicio en desarrollo**: lanza el proxy `decap-server` (minimizado) y luego `npm run dev`.

## Estado actual

- [x] Documentación base (README, .gitignore, MEMORY, AGENTS)
- [x] Inicializar proyecto Astro (`npm create astro@latest` → Astro 7.1.6)
- [x] Landing page con navbar responsivo
- [x] Blog (listado + página individual `[slug]`)
- [x] Integrar Decap CMS (`/admin` + `config.yml` + `local_backend`)
- [x] Proxy local `decap-server` instalado como devDependency
- [x] Workflow `.github/workflows/deploy.yml` para GitHub Pages (rebuild automático con cada push a `main`)
- [x] `site` configurado en `astro.config.mjs` → subdominio `astrojs-blog-integration-cms-decapcms.edgardovasquez.cl`
- [x] Custom domain + `build_type: workflow` configurados en GitHub (vía API)
- [ ] **Usuario**: registrar CNAME en Cloudflare (`astrojs-blog-integration-cms-decapcms` → `edgardo001.github.io`, DNS-only) — **en proceso: el sitio ya responde en el subdominio**
- [x] `backend.repo` en `config.yml` = `edgardo001/astrojs-blog-integration-cms-decapcms`
- [ ] Repo debe ser **público** para GitHub Pages gratuito (requisito confirmado)
- [ ] Configurar `backend.repo` en `config.yml` con el repo real (usuario/repo)
- [ ] Desplegar en GitHub Pages (repo `edgardo001.github.io`) — **decidido: GitHub Pages, no Netlify**

## Bitácora (historial cronológico)

### 2026-08-02 — Setup del proyecto

1. Se crearon `README.md`, `.gitignore`, `MEMORY.md`, `AGENTS.md`.
2. Se confirmó que Astro está en la **v7.1** (astro.build).
3. Se decidió priorizar el **blog + Decap CMS**; la landing es básica.
4. Se creó `start-dev.bat` (igual que en `edgardo001.github.io`: solo `npm run dev`).
5. Se inicializó el proyecto con `npm create astro@latest --template minimal --typescript strict --no-git --install`.
   - Nota: npm pasó `--typescript` como nombre de carpeta; se movieron los archivos a la raíz y se eliminó la subcarpeta sobrante.
   - Se corrigió `package.json` (name era `--typescript`) y se agregó el script `check` (`astro check`) + `@astrojs/check` y `typescript` como devDeps.
6. Se crearon: `global.css`, `Layout.astro`, `Navbar.astro` (hamburguesa), `Footer.astro`, landing (`index.astro`), `404.astro`.
7. Content collection `blog` en `src/content.config.ts` + 2 posts de ejemplo (`bienvenido-a-miblog.md`, `astro-y-decap-cms.md`).
8. Rutas del blog: listado en `src/pages/blog/index.astro` y post individual en `src/pages/blog/[slug].astro`.
9. Integración Decap CMS: `src/pages/admin.html` (CDN) y `public/admin/config.yml` (colección `blog` con campos en español).
10. Verificación: `npm run check` → 0 errores/warnings; `npm run build` → 6 páginas; smoke test del dev server en `localhost:4321` → todas las rutas 200.

### 2026-08-02 — Autenticación de Decap CMS

1. Se explicó que Decap CMS **no usa usuario/contraseña propios**.
2. Se agregó `local_backend: true` al `config.yml` para permitir local **y** GitHub a la vez.
3. Se instaló `decap-server` como devDependency (proxy local en el puerto 8081).
4. Se creó `FAQ.md` con las preguntas y respuestas sobre autenticación (MEMORY queda solo para el proyecto).

### 2026-08-02 — Decisión de despliegue: GitHub Pages

1. El usuario confirmó que el sitio se desplegará en **GitHub Pages** (no Netlify).
2. Se cambió el backend de Decap CMS de `git-gateway` (exclusivo de Netlify) a `github` con `repo: TU_USUARIO/TU_REPO` (placeholder por llenar).
3. El OAuth por defecto del backend `github` lo facilita Netlify; alternativa: OAuth client propio. En local sigue todo igual con `local_backend`.
4. Se eliminó `start-cms.bat`: `start-dev.bat` es ahora la única fuente de inicio en desarrollo (levanta `decap-server` + `npm run dev`).
5. `start-dev.bat` ahora usa `start /b` para que `decap-server` corra en la **misma consola**: cerrar la ventana apaga todo (dev server + proxy).

### 2026-08-02 — GitHub Pages: workflow y documentación

1. Se creó `.github/workflows/deploy.yml` (checkout → node 22 → `npm ci` → `npm run build` → upload artifact → deploy-pages). Se dispara en cada push a `main` (incluye commits del CMS) y con `workflow_dispatch`.
2. Se configuró `site: 'https://edgardo001.github.io'` en `astro.config.mjs`.
3. Se documentó en README y FAQ: cómo llegan los posts al build (commits del CMS), cierre de `start-dev.bat`, y pasos de despliegue (repo público, source "GitHub Actions", workflow).
4. FAQ.md quedó con todas las preguntas registradas del usuario.

### 2026-08-02 — SEO social y posts con imágenes reales

1. Los posts de muestra pasaron a usar **fotos reales** (3 por post: portada + medio + final) en `public/uploads/` (media folder del CMS).
2. Se agregaron **Open Graph** (`og:*`) y **Twitter Cards** (`twitter:*`) en `src/layouts/Layout.astro`, con `og:image` en URL absoluta desde `Astro.site` + `image` del frontmatter, `og:type=article` en posts, canonical y favicon.

### 2026-08-02 — Subdominio personalizado + Cloudflare

1. El sitio se sirve en **`https://astrojs-blog-integration-cms-decapcms.edgardovasquez.cl`** (raíz del subdominio).
2. `astro.config.mjs`: `site` apunta al subdominio; sin `base` (raíz). Rutas internas usan `import.meta.env.BASE_URL`.
3. Se eliminó el plugin rehype de prefijo de imágenes y `@astrojs/markdown-remark` (innecesarios con raíz).
4. En GitHub (API): custom domain del project site = subdominio + `build_type: workflow`.
5. **Pendiente del usuario**: registrar CNAME en Cloudflare (`astrojs-blog-integration-cms-decapcms` → `edgardo001.github.io`, DNS-only) para que GitHub verifique el dominio y habilite HTTPS.

### 2026-08-02 — Login de Decap CMS y repo real

1. El login de Decap redirige a `api.netlify.com` — **comportamiento por defecto** del backend `github` (proxy OAuth de Netlify). El usuario confirmó usarlo tal cual (sin OAuth App propia).
2. Se corrigió `backend.repo` en `public/admin/config.yml` (era placeholder `TU_USUARIO/TU_REPO`) → `edgardo001/astrojs-blog-integration-cms-decapcms`.
3. El sitio quedó funcionando en `https://astrojs-blog-integration-cms-decapcms.edgardovasquez.cl/` (200 en `/` y `/blog/`).

## Convenciones

- Textos de UI en **español**.
- Sin comentarios de código salvo que se pidan.
- Rutas de páginas: `index`, `blog`, `blog/[slug]`, `404`, `admin`.
- Verificación obligatoria: `npm run check` y `npm run build` después de cambios.

## Enlaces de referencia

- Astro: https://astro.build | Docs content collections: https://docs.astro.build/en/guides/content-collections/
- Decap CMS: https://github.com/decaporg/decap-cms | Docs: https://decapcms.org/docs/
- Guía oficial Astro + Decap CMS: https://docs.astro.build/en/guides/cms/decap-cms/
- Proxy local: https://decapcms.org/docs/working-with-a-local-git-repository/
