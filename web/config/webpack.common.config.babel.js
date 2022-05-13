import { resolve } from "path";
import Dotenv from "dotenv-webpack";
import ForkTsCheckerWebpackPlugin from "fork-ts-checker-webpack-plugin";
import ESLintPlugin from "eslint-webpack-plugin";
import HtmlWebpackPlugin from "html-webpack-plugin";

const BABEL_CONFIG = {
  presets: ["@babel/env", "@babel/react", "@babel/preset-typescript"],
  plugins: ["@babel/proposal-class-properties"],
};

module.exports = {
  entry: {
    app: resolve("./src/index.tsx"),
  },

  output: {
    library: "App",
  },

  resolve: {
    extensions: [".js", ".jsx", ".tsx", ".ts"],
    alias: {
      "mapbox-gl": "maplibre-gl",
    },
  },

  plugins: [
    new HtmlWebpackPlugin({
      template: resolve("./src/index.html"),
    }),
    new Dotenv({ systemvars: true }),
    new ForkTsCheckerWebpackPlugin({
      async: false,
    }),
    new ESLintPlugin({
      extensions: ["js", "jsx", "ts", "tsx"],
    }),
  ],

  module: {
    rules: [
      {
        test: /\.(ts|js)x?$/i,
        include: [resolve(".")],
        exclude: /node_modules/,
        use: [
          {
            loader: "babel-loader",
            options: BABEL_CONFIG,
          },
        ],
      },
      {
        test: /\.(sa|c)ss$/,
        exclude: /\.module\.(sa|c)ss$/,
        use: ["style-loader", "css-loader"],
      },
      {
        test: /\.module\.(sa|c)ss$/,
        use: [
          "style-loader",
          "@teamsupercell/typings-for-css-modules-loader",
          {
            loader: "css-loader",
            options: { modules: true },
          },
        ],
      },
      {
        test: /\.md$/,
        use: "raw-loader",
      },
    ],
  },
};
