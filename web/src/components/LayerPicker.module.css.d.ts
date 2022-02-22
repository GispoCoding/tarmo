declare namespace LayerPickerModuleCssNamespace {
  export interface ILayerPickerModuleCss {
    LayerPicker: string;
  }
}

declare const LayerPickerModuleCssModule: LayerPickerModuleCssNamespace.ILayerPickerModuleCss & {
  /** WARNING: Only available when `css-loader` is used without `style-loader` or `mini-css-extract-plugin` */
  locals: LayerPickerModuleCssNamespace.ILayerPickerModuleCss;
};

export = LayerPickerModuleCssModule;
