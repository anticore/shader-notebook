import { ChainOptions, ShaderOptions } from "@anticore/boavista/dist/gl/chain";
import { BindingParams } from "tweakpane";

export interface UniformConfig {
  name: string;
  value: number | string | number[];
  options?: BindingParams;
}

export interface NotebookShaderConfig {
  name: string;
  shaders: ShaderOptions[];
  uniforms?: UniformConfig[];
}

export type NotebookConfig = NotebookShaderConfig[];
