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
import { addFPS, addMonitors, createPane, createUniforms } from "./Pane";
import { addControls } from "./Pane";
import { type ShaderConfig } from "../types";
import { dopesheet } from "@anticore/ooru-dopesheet";
import { type ParsedSheet } from "@anticore/ooru-dopesheet/dist/dopesheet";

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
      addControls();
      const fps = addFPS();
      // create uniforms from config and add them to pane
      createUniforms(uniforms.current, shader.uniforms);

      addMonitors(uniforms.current, [["t", { interval: 10 }]]);

      // load dopesheet
      let sheet: ParsedSheet | null = null;
      if (shader.sheet) {
        sheet = dopesheet(shader.sheet);

        if (shader.sheetMonitors) {
          const sheetValues = sheet.get(0);
          uniforms.current.dA1 = sheetValues.analog[0];
          uniforms.current.dA2 = sheetValues.analog[1];
          uniforms.current.dA3 = sheetValues.analog[2];
          uniforms.current.dA4 = sheetValues.analog[3];
          uniforms.current.dA5 = sheetValues.analog[4];
          uniforms.current.dA6 = sheetValues.analog[5];
          uniforms.current.dA7 = sheetValues.analog[6];
          uniforms.current.dA8 = sheetValues.analog[7];

          addMonitors(uniforms.current, [
            ["dA1", { view: "graph", min: 0, max: 5 }],
            ["dA2", { view: "graph", min: 0, max: 5 }],
            ["dA3", { view: "graph", min: 0, max: 5 }],
            ["dA4", { view: "graph", min: 0, max: 5 }],
          ]);
        }
      }

      const loop = timer((time: number) => {
        if (fps) fps.begin();

        // update uniforms
        if (uniforms.current) {
          uniforms.current.t = time % 8;

          if (sheet) {
            const sheetValues = sheet.get(uniforms.current.t);

            uniforms.current.dA1 = sheetValues.analog[0];
            uniforms.current.dA2 = sheetValues.analog[1];
            uniforms.current.dA3 = sheetValues.analog[2];
            uniforms.current.dA4 = sheetValues.analog[3];
            uniforms.current.dA5 = sheetValues.analog[4];
            uniforms.current.dA6 = sheetValues.analog[5];
            uniforms.current.dA7 = sheetValues.analog[6];
            uniforms.current.dA8 = sheetValues.analog[7];
          }
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
