import { defineConfig } from "vite";
import { glsl } from "@anticore/ooru-glsl/dist/glsl.js";
import react from "@vitejs/plugin-react-swc";

export default defineConfig({
  plugins: [react(), glsl({ dir: __dirname })],
  base: "https://anticore.github.io/shader-notebook/",
});
