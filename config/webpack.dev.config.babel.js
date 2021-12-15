// @ts-ignore
import CommonConfig from "./webpack.common.config.babel";

module.exports = {
  ...CommonConfig,
  mode: "development",
  devServer: {
    port: 3000,
    open: true,
    hot: true,
  },
};
