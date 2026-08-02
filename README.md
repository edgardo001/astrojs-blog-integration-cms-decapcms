# AstroJS + Decap CMS — Blog con Landing Page

Landing page responsiva (móvil y desktop) con navbar, más un blog administrado con **Decap CMS** y construido con **AstroJS**.

## Tecnologías

- **[AstroJS](https://astro.build)** — Framework de contenido estático (v7).
- **[Decap CMS](https://github.com/decaporg/decap-cms)** — CMS de Git-based para administrar el blog.
- **Markdown** — Los posts del blog se escriben en `src/content/blog/` con Frontmatter.

## Estructura del proyecto

```
.
├── public/
│   ├── admin/          # Widget de Decap CMS (index.html + config.yml)
│   └── uploads/        # Imágenes subidas desde Decap CMS
├── src/
│   ├── components/     # Componentes reutilizables (Navbar, Footer, ...)
│   ├── content/
│   │   ├── blog/       # Posts del blog (Markdown)
│   │   └── config.ts   # Esquema del content collection "blog"
│   ├── layouts/        # Layouts (Layout.astro, BlogPost.astro, ...)
│   └── pages/          # Rutas: index, blog, blog/[slug], 404, ...
├── astro.config.mjs
├── package.json
└── tsconfig.json
```

## Requisitos previos

- Node.js 20 o superior
- npm (o pnpm / yarn / bun)

## Puesta en marcha

```bash
# Instalar dependencias
npm install

# Desarrollo en Windows (levanta el proxy de Decap CMS y el dev server)
start-dev.bat

# Alternativa: servidor de desarrollo solo
npm run dev

# Build de producción
npm run build

# Previsualizar el build
npm run preview

# Lint / typecheck (si están configurados)
npm run lint
npm run check
```

## Configurar Decap CMS

Decap CMS **no usa usuario/contraseña propios**: en producción autentica vía **DecapBridge** y en local funciona sin credenciales.

1. **Local (sin credenciales)**: el proyecto usa `local_backend: true`. Ejecuta `start-dev.bat` (o en terminales separadas: `npx decap-server` + `npm run dev`). Luego abre `http://localhost:4321/admin/`. Los cambios se escriben directo en el repo local.

2. **Producción (GitHub Pages)**: el backend es `git-gateway` con **DecapBridge** (auth PKCE). El login lo gestiona DecapBridge (contraseña, Google o Microsoft) para los colaboradores invitados; los commits se firman con el nombre del autor. Ver el setup en el `FAQ.md`.

> No hace falta apagar `local_backend` al desplegar: si el proxy no está corriendo, el CMS usa automáticamente el backend remoto definido en `config.yml`.

## Escribir posts

Dos opciones:

1. **Desde el CMS**: entrar en `/admin/`, autenticarse y crear contenido desde la interfaz.
2. **Directo en el repo**: crear un archivo `src/content/blog/mi-post.md` siguiendo el frontmatter del esquema en `src/content.config.ts`.

> Al compilar, Astro lee los `.md` ya presentes en `src/content/blog/` (loader `glob()`). El CMS es quien los escribe ahí haciendo commits al repo; no consulta al CMS en build.

## Despliegue en GitHub Pages

1. Repo **público** y en Settings → Pages seleccionar **GitHub Actions** como source.
2. `site` en `astro.config.mjs` apunta a **`https://astrojs-blog-integration-cms-decapcms.edgardovasquez.cl`** (subdominio personalizado).
3. Configurar `backend.repo` en `public/admin/config.yml` con `usuario/repo`.
4. El workflow `.github/workflows/deploy.yml` construye y publica el sitio en cada push a `main`, **incluidos los commits del CMS**, así los posts nuevos aparecen solos.

### Dominio personalizado

- El sitio vive en `https://astrojs-blog-integration-cms-decapcms.edgardovasquez.cl`, servido en la **raíz** del subdominio.
- El DNS está en **Cloudflare**: agregar un registro **CNAME** `astrojs-blog-integration-cms-decapcms` → `edgardo001.github.io` (proxy DNS-only).
- El dominio personalizado del project site se configura en el repo (Settings → Pages → Custom domain); GitHub lo verifica y emite el HTTPS automáticamente.
- El dominio `edgardovasquez.cl` pertenece al *user site* `edgardo001.github.io`; de ahí salen las redirecciones `github.io` → `edgardovasquez.cl`.

```mermaid
flowchart LR
    E[Editor] -->|escribe post| CMS[Decap CMS /admin]
    CMS -->|commit al repo| GH[(GitHub)]
    GH -->|push a main| W[GitHub Actions]
    W -->|npm run build| D[dist/]
    D -->|deploy-pages| P[(GitHub Pages)]
    P -->|publica| SITE[Sitio público]
```

## Comandos útiles

| Comando            | Acción                            |
| ------------------ | --------------------------------- |
| `npm install`      | Instala dependencias              |
| `npm run dev`      | Inicia servidor de desarrollo     |
| `npm run build`    | Genera el sitio estático          |
| `npm run preview`  | Previsualiza el build             |
| `npm run check`    | Typecheck + validación de content |

## Licencia

MIT
