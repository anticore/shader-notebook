import { createCanvas } from "@anticore/boavista/dist/page/createCanvas";
import { createProgram } from "@anticore/boavista/dist/gl/createProgram";
import { resizeCanvas } from "@anticore/boavista/dist/page/resizeCanvas";
import { initGL } from "@anticore/boavista/dist/gl/initGL";
import { vert } from "@anticore/boavista/dist/gl/vert";
import { renderToScreen } from "@anticore/boavista/dist/gl/renderToScreen";
import { timer } from "@anticore/boavista/dist/util/timer";
import { useEffect, useRef } from "react";
import { addFPS, addMonitors, createPane, createUniforms } from "./Pane";
import { addControls } from "./Pane";
import { dopesheet } from "@anticore/dopesheet";
import { type ParsedSheet } from "@anticore/dopesheet/dist/dopesheet";
import { chain, type ShaderOptions } from "@anticore/boavista/dist/gl/chain";

export interface RendererProps {
  shaders: ShaderOptions[];
  sheet?: string;
}

function Renderer({ shaders, sheet }: RendererProps) {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const loaded = useRef<boolean>(false);
  const uniforms = useRef<{ [key: string]: number | string | number[] } | null>(
    null
  );

  useEffect(() => {
    if (loaded.current) return;

    console.log(shaders);

    if (!shaders) return;
    if (canvasRef.current) {
      const canvas = createCanvas(canvasRef.current);

      canvas && resizeCanvas(canvas);
      addEventListener("resize", () => {
        canvas && resizeCanvas(canvas);
      });

      const gl = initGL({ canvas });
      const c = chain({ gl, shaders })!;

      const defaultUniforms = {
        t: 0,
        r: [canvas.width, canvas.height],
      };

      uniforms.current = defaultUniforms;

      createPane();
      addControls();
      const fps = addFPS();
      // create uniforms from config and add them to pane
      // FIXME: createUniforms(uniforms.current, shaders);

      addMonitors(uniforms.current, [["t", { interval: 10 }]]);

      /*if (shader.sizeUniforms) {
        // eslint-disable-next-line
        addMonitors(canvas as any, [["width", { interval: 10 }]]);
        // eslint-disable-next-line
        addMonitors(canvas as any, [["height", { interval: 10 }]]);
      }
      */

      // load dopesheet
      let pSheet: ParsedSheet | null = null;
      if (sheet) {
        pSheet = dopesheet(sheet);

        /*
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
        */
      }

      const loop = timer((time: number) => {
        if (fps) fps.begin();

        // update uniforms
        if (uniforms.current) {
          uniforms.current.t = time;

          if (canvasRef.current) {
            uniforms.current.r = [
              canvasRef.current.width,
              canvasRef.current.height,
            ];
          }

          if (pSheet) {
            const sheetValues = pSheet.get(uniforms.current.t);

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

        console.log("123");

        c({
          gl,
          uniforms: uniforms.current || defaultUniforms,
        });

        if (fps) fps.end();
      });
      loop.start();
      loaded.current = true;
    }
  }, [shaders]);

  return <canvas ref={canvasRef} />;
}

export default Renderer;
