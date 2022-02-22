declare namespace LayerPickerModuleSassNamespace {
  export interface ILayerPickerModuleSass {
    LayerPicker: string;
  }
}

declare const LayerPickerModuleSassModule: LayerPickerModuleSassNamespace.ILayerPickerModuleSass & {
  /** WARNING: Only available when `css-loader` is used without `style-loader` or `mini-css-extract-plugin` */
  locals: LayerPickerModuleSassNamespace.ILayerPickerModuleSass;
};

export = LayerPickerModuleSassModule;
