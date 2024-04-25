// @ts-nocheck

import { defineConfig } from "vite";
import { glsl } from "@anticore/boavista/dist/plugin/glsl";
import react from "@vitejs/plugin-react-swc";

const fullReloadAlways = {
  name: "full-reload-always",
  handleHotUpdate({ server }) {
    server.ws.send({ type: "full-reload" });
    return [];
  },
};

export default defineConfig({
  plugins: [
    react(),
    glsl({
      dir: __dirname,
    }),
    fullReloadAlways,
  ],
  base: "https://anticore.github.io/shader-notebook/",
  build: {
    chunkSizeWarningLimit: 99999999,
  },
});
