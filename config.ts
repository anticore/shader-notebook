import { ShaderConfig } from "./src/types";

import glowBallsFrag from "./shaders/glowBalls.glsl";
import checkerFrag from "./shaders/checker.glsl";
import lineworkFrag from "./shaders/linework.glsl";
import dopesheetFrag from "./shaders/dopesheet/frag.glsl";
import dopesheetSheet from "./shaders/dopesheet/sheet.dope?raw";
import spike01Frag from "./shaders/spike_01/spike_01.glsl";
import spike01Sheet from "./shaders/spike_01/spike_01.dope?raw";

const shaderIndex: ShaderConfig[] = [
  {
    name: "glowBalls",
    frag: glowBallsFrag,
  },
  {
    name: "checker",
    frag: checkerFrag,
    uniforms: [
      {
        name: "squareSize",
        value: 1,
        options: { min: -10, max: 10, step: 0.001 },
      },
    ],
  },
  {
    name: "linework",
    frag: lineworkFrag,
  },
  {
    name: "dopesheet",
    frag: dopesheetFrag,
    sheet: dopesheetSheet,
    sheetMonitors: true,
  },
  {
    name: "spike_01",
    frag: spike01Frag,
    sheet: spike01Sheet,
    hideCode: true,
    timeUniform: true,
    sizeUniforms: true,
  },
];

export default shaderIndex;
