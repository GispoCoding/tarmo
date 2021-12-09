import { resolve } from "path";
import CommonConfig from "./webpack.common.config.babel";
import { CleanWebpackPlugin } from "clean-webpack-plugin";

module.exports = {
  ...CommonConfig,
  mode: "production",
  output: {
    path: resolve(__dirname, "..", "dist"),
    filename: "[name].[contenthash].js",
    publicPath: "",
  },
  plugins: [...CommonConfig.plugins, new CleanWebpackPlugin()],
};
