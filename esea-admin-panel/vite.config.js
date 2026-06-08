import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { sentryVitePlugin } from "@sentry/vite-plugin";

export default defineConfig({
  plugins: [
    react(),
    sentryVitePlugin({
      org: process.env.SENTRY_ORG || "esea",
      project: process.env.SENTRY_PROJECT || "esea-admin",
    }),
  ],
  build: {
    sourcemap: true,
  }
})
