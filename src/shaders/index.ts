import glowBallsFrag from "./glowBalls.glsl";
import checkerFrag from "./checker.glsl";
import lineworkFrag from "./linework.glsl";
import { BindingParams } from "tweakpane";
import { getPane } from "../ui/Pane";

export interface UniformConfig {
  name: string;
  value: number | string | number[];
  options?: BindingParams;
}

export interface ShaderConfig {
  name: string;
  // TODO: add other info args like title, date,...

  frag: string;

  uniforms?: UniformConfig[];
}

export const createUniforms = (
  inUniforms: { [key: string]: number | string | number[] },
  uniforms?: UniformConfig[]
) => {
  if (!uniforms || uniforms.length === 0) return inUniforms;

  uniforms.forEach((uniform) => {
    inUniforms[uniform.name] = uniform.value;
    getPane()?.addBinding(inUniforms, uniform.name, uniform.options);
  });

  return inUniforms;
};

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
];

export default shaderIndex;
