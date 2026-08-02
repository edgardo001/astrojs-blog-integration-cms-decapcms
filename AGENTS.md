# AGENTS.md

Guía para agentes de IA que trabajen en este repositorio.

## Comandos obligatorios

Después de cualquier cambio en el código, ejecutar en este orden (si están configurados):

```bash
npm run check     # Typecheck de Astro + validación de content collections
npm run lint      # Lint (si existe)
```

## Estructura clave

- `src/pages/` — Rutas del sitio (index, blog, blog/[slug], 404).
- `src/layouts/` — Layouts compartidos.
- `src/components/` — Componentes (Navbar, Footer, etc.).
- `src/content/blog/` — Posts del blog en Markdown.
- `src/content.config.ts` — Esquema/validador del content collection `blog` (Astro 7).
- `public/admin/` — Configuración y widget de Decap CMS.
- `public/uploads/` — Imágenes subidas desde el CMS.

## Reglas de trabajo

1. **Textos en español**: toda la UI y contenido del sitio en español.
2. **Sin comentarios**: no agregar comentarios al código salvo que el usuario lo pida.
3. **Responsividad**: toda sección debe funcionar en móvil y desktop (mobile-first).
4. **No tocar frontmatter**: no cambiar `src/content/config.ts` sin validar que los posts existentes sigan siendo válidos (`npm run check`).
5. **Seguir patrones existentes**: reutilizar componentes/layouts ya creados; no duplicar estilos.
6. **No commitear** a menos que el usuario lo pida explícitamente.
7. **Mantener los .md actualizados**: después de cualquier cambio relevante, actualizar los archivos Markdown del repo, cada uno con su contenido correspondiente:
   - `README.md` — descripción, estructura, comandos e instrucciones de uso.
   - `MEMORY.md` — contexto del proyecto, decisiones, bitácora y estado.
   - `AGENTS.md` — reglas e instrucciones para agentes de IA.
   - `FAQ.md` — preguntas frecuentes y sus respuestas.
   - No duplicar contenido entre ellos; cada archivo debe reflejar solo lo que le corresponde.
8. **Diagramas Mermaid**: si es necesario para mayor comprensión, se pueden agregar diagramas Mermaid a los `.md` del repo (flows, arquitectura, secuencias, etc.). Preferir cuando un proceso sea complejo de explicar solo con texto.

## Notas Decap CMS

- El backend apunta a GitHub; ajustar `backend.repo` en `public/admin/config.yml` con `usuario/repo`.
- En local, abrir `/admin/` con el servidor de desarrollo. Para producción en GitHub Pages, revisar el método de auth (git-gateway requiere Netlify o un proxy).
- Las entradas del CMS se guardan como Markdown en `src/content/blog/`, compatibles con Content Collections de Astro.

## Verificación

- Antes de dar una tarea por terminada: `npm run build` debe pasar sin errores.
- Para cambios en el esquema de contenido: `npm run check`.

## Git

- **Commits atómicos**: un commit por cambio lógico.
- **Usa [Conventional Commits](https://www.conventionalcommits.org/)**:
  - `feat(scope):` — nueva funcionalidad o ejemplo
  - `fix(scope):` — corrección de bugs o errores de compilación
  - `docs(scope):` — cambios en README, comentarios, documentación
  - `refactor(scope):` — reestructuración sin cambiar comportamiento
  - `style(scope):` — cambios de formato, espacios, indentación
  - `chore(scope):` — dependencias, configs, archivos auxiliares
  - `perf(scope):` — mejoras de rendimiento
  - `test(scope):` — agregar o modificar tests
  - `ci(scope):` — cambios en pipelines CI/CD
- **Scope**: nombre del componente o módulo afectado (ej. `feat(skills):`, `fix(hero):`).
- **Body explicativo** cuando el cambio no es obvio.
- **Commit messages en inglés**, claros y descriptivos.
- **No commitea** `node_modules/`, `dist/`, `.astro/`, ni archivos temporales.
- **Verifica estado** antes de commitear (`git status`, `git diff`).
- **Push** solo cuando el Líder Técnico aprueba la revisión completa.
