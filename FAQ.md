# FAQ

Preguntas frecuentes del proyecto y sus respuestas.

## ¿Cómo sé mi usuario y contraseña de Decap CMS?

Decap CMS **no tiene usuario/contraseña propios**. Autentica contra GitHub (OAuth) o funciona sin credenciales en local. Opciones:

- **Local**: backend local (`local_backend: true`) + `npx decap-server`. Escribe directo en el disco, sin login.
- **Producción**: GitHub OAuth App (backend `github`) o Netlify Identity (backend `git-gateway`). Es OAuth, no usuario/contraseña.

## ¿Puedo tener ambos, backend local y GitHub?

Sí. Con `local_backend: true` en el mismo `config.yml`:

- En local, `decap-server` (proxy) escribe al filesystem local.
- En producción, sin proxy activo, se usa el backend remoto configurado.

## ¿Debo apagar `local_backend: true` en producción?

**No.** Si el proxy local no está corriendo (producción), Decap CMS cae automáticamente al backend remoto definido en `config.yml`. No hace falta modificar nada al desplegar.

## ¿Funciona Decap CMS en GitHub Pages (sin Netlify)?

Sí, pero con el backend `github`, no `git-gateway` (que es un servicio exclusivo de Netlify). En `config.yml`:

```yaml
backend:
  name: github
  repo: tu-usuario/tu-repo
  branch: main
```

- Los editores se loguean con su cuenta de GitHub (deben tener push access al repo).
- El OAuth por defecto lo facilita Netlify; también se puede usar un [OAuth client propio](https://decapcms.org/docs/external-oauth-clients/).
- En local todo sigue igual con `local_backend` + `decap-server`.

## ¿Debe ser público el repositorio?

**Sí**, para usar GitHub Pages gratuito el repo debe ser **público** (GitHub Pages en repos privados requiere plan de pago). Con repo público, Decap (backend `github`) usa el OAuth por defecto y los editores se loguean con su cuenta de GitHub.

Con repo privado, además del costo de GitHub Pages, necesitarías crear tu propia GitHub OAuth App para que el CMS acceda al repo.

## ¿Cómo creo un nuevo post?

Dos opciones:

1. Desde el CMS: levanta el proxy (`npx decap-server`), abre `/admin/` y crea el contenido.
2. Directo en el repo: crea un archivo `src/content/blog/mi-post.md` siguiendo el frontmatter de `src/content.config.ts`.

## ¿Cómo llegan los posts a `src/content/blog` al compilar Astro?

Astro no consulta al CMS en compilación: lee los `.md` que ya existen en `src/content/blog/` mediante el loader `glob()` de `src/content.config.ts`. Quien los escribe ahí es Decap CMS haciendo un **commit directo al repositorio**:

1. El editor escribe/edita un post en `/admin/`.
2. Decap hace commit del archivo al repo (`src/content/blog/mi-post.md`).
3. El commit dispara el rebuild de GitHub Actions → `astro build` lee el `.md` y genera el HTML.

En local, el proxy `decap-server` escribe el `.md` directo en el disco y el dev server lo detecta al instante. Por eso en GitHub Pages el commit del CMS debe disparar el build del workflow, o los posts no aparecen hasta el siguiente deploy.

## ¿Qué pasa si cierro la ventana de `start-dev.bat`?

Se apaga todo. `start-dev.bat` lanza el proxy `decap-server` con `start /b` (misma consola) y luego `npm run dev`. Al cerrar la ventana, Windows termina todos los procesos de esa consola: dev server y proxy. No queda ningún proceso colgado.

## ¿Cómo despliego y publico cambios?

1. El repo debe ser **público** y conectado a GitHub Pages.
2. En Settings → Pages, elige "GitHub Actions" como source.
3. El workflow `.github/workflows/deploy.yml` construye y publica el sitio en cada push a `main` (incluidos los commits del CMS).
4. El `site` configurado en `astro.config.mjs` debe apuntar a la URL real (ej. `https://edgardo001.github.io`).

## ¿Cómo sabe GitHub cuál es mi dominio?

Porque se lo configuras tú: en **Settings → Pages → Custom domain** guardas el dominio, y el **DNS** del dominio apunta a GitHub Pages (un CNAME hacia `edgardo001.github.io`). GitHub verifica el registro y emite el certificado HTTPS. El dominio `edgardovasquez.cl` está configurado en el *user site* `edgardo001.github.io`, y de ahí sale la redirección `github.io` → `edgardovasquez.cl`.

## ¿En qué URL vive el sitio?

En el subdominio **`https://astrojs-blog-integration-cms-decapcms.edgardovasquez.cl`** (raíz, sin subcarpeta). El DNS está en Cloudflare:

- Registro **CNAME**: nombre `astrojs-blog-integration-cms-decapcms` → destino `edgardo001.github.io`, con proxy **DNS-only** (nube gris).
- Una vez el DNS resuelva, GitHub verifica el dominio y habilita HTTPS automáticamente.
