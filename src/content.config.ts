import { defineCollection } from "astro:content";
import { glob } from "astro/loaders";
import { z } from "astro/zod";

const postSchema = z.object({
  title: z.string(),
  description: z.string().optional(),
  pubDate: z.coerce.date(),
  author: z.string().optional(),
  image: z.string().optional(),
  tags: z.array(z.string()).optional(),
});

const blog = defineCollection({
  loader: glob({ base: "./src/content/blog", pattern: "**/*.{md,mdx}" }),
  schema: postSchema,
});

const blog_rrhh = defineCollection({
  loader: glob({ base: "./src/content/blog_rrhh", pattern: "**/*.{md,mdx}" }),
  schema: postSchema,
});

const blog_interno = defineCollection({
  loader: glob({ base: "./src/content/blog_interno", pattern: "**/*.{md,mdx}" }),
  schema: postSchema,
});

const blog_externo = defineCollection({
  loader: glob({ base: "./src/content/blog_externo", pattern: "**/*.{md,mdx}" }),
  schema: postSchema,
});

const blog_comunicados = defineCollection({
  loader: glob({
    base: "./src/content/blog_comunicados",
    pattern: "**/*.{md,mdx}",
  }),
  schema: postSchema,
});

export const collections = {
  blog,
  blog_rrhh,
  blog_interno,
  blog_externo,
  blog_comunicados,
};

export type BlogCollectionName = keyof typeof collections;
