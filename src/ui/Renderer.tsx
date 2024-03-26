import {
  createCanvas,
  createProgram,
  resizeCanvas,
  initGL,
} from "@anticore/ooru-core";
import vert from "@anticore/ooru-glsl/dist/glsl/defaultVert.glsl";
import { renderToScreen } from "@anticore/ooru-core/dist/gl/renderToScreen";
import { timer } from "@anticore/ooru-core/dist/util/timer";
import { useEffect, useRef } from "react";
import { ShaderConfig, createUniforms } from "../shaders";
import { addFPS, createPane } from "./Pane";

export interface RendererProps {
  shader: ShaderConfig;
}

function Renderer({ shader }: RendererProps) {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const loaded = useRef<boolean>(false);
  const uniforms = useRef<{ [key: string]: number | string | number[] } | null>(
    null
  );

  useEffect(() => {
    if (loaded.current) return;

    if (canvasRef.current) {
      const canvas = createCanvas(canvasRef.current);

      canvas && resizeCanvas(canvas);
      addEventListener("resize", () => {
        canvas && resizeCanvas(canvas);
      });

      const gl = initGL({ canvas });
      const program = createProgram({ gl, vert, frag: shader.frag })!;

      const defaultUniforms = {
        t: 0,
        r: [canvas.width, canvas.height],
      };

      uniforms.current = defaultUniforms;

      createPane();
      const fps = addFPS();
      // create uniforms from config and add them to pane
      createUniforms(uniforms.current, shader.uniforms);

      const loop = timer((time: number) => {
        if (fps) fps.begin();

        // update uniforms
        if (uniforms.current) {
          uniforms.current.t = time;
        }

        renderToScreen({
          gl,
          program,
          uniforms: uniforms.current || defaultUniforms,
        });

        if (fps) fps.end();
      });
      loop.start();
      loaded.current = true;
    }
  }, [shader]);

  return <canvas ref={canvasRef} />;
}

export default Renderer;
