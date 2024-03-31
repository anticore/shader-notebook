import { BindingParams } from "tweakpane";

export interface UniformConfig {
  name: string;
  value: number | string | number[];
  options?: BindingParams;
}

export interface ShaderConfig {
  name: string;
  // TODO: add other info args like title, date,...

  frag: string;

  sheet?: string;
  sheetMonitors?: boolean;

  uniforms?: UniformConfig[];
  timeUniform?: boolean;
  sizeUniforms?: boolean;

  hideCode?: boolean;
}
