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

export interface RendererProps {
  shader: string;
}

function Renderer({ shader }: RendererProps) {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  useEffect(() => {
    if (canvasRef.current) {
      const canvas = createCanvas(canvasRef.current);

      resizeCanvas(canvas);
      addEventListener("resize", () => {
        canvas && resizeCanvas(canvas);
      });

      const gl = initGL({ canvas });
      const program = createProgram({ gl, vert, frag: shader })!;

      const loop = timer((time: number) => {
        renderToScreen({
          gl,
          program,
          uniforms: { t: time, r: [canvas.width, canvas.height] },
        });
      });
      loop.start();
    }
  }, [shader]);

  return <canvas ref={canvasRef} />;
}

export default Renderer;
