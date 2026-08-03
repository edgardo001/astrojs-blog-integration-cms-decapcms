import type { BlogCollectionName } from "../content.config";

export interface BlogInfo {
  name: BlogCollectionName;
  label: string;
  description: string;
  navLabel: string;
  backLabel: string;
  enabled: boolean;
}

export const blogs: BlogInfo[] = [
  {
    name: "blog",
    label: "Blog",
    description: "Todas las publicaciones del blog",
    navLabel: "Blog",
    backLabel: "Volver al blog",
    enabled: true,
  },
  {
    name: "blog_rrhh",
    label: "Blog RRHH",
    description: "Noticias y novedades de Recursos Humanos",
    navLabel: "RRHH",
    backLabel: "Volver a Blog RRHH",
    enabled: true,
  },
  {
    name: "blog_interno",
    label: "Blog Interno",
    description: "Información para el equipo interno de la organización",
    navLabel: "Interno",
    backLabel: "Volver al blog interno",
    enabled: true,
  },
  {
    name: "blog_externo",
    label: "Blog Externo",
    description: "Artículos y novedades dirigidas al público externo",
    navLabel: "Externo",
    backLabel: "Volver al blog externo",
    enabled: true,
  },
  {
    name: "blog_comunicados",
    label: "Blog Comunicados",
    description: "Comunicados oficiales de la organización",
    navLabel: "Comunicados",
    backLabel: "Volver a comunicados",
    enabled: true,
  },
];
