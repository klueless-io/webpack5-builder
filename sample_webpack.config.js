const HtmlWebpackPlugin = require("html-webpack-plugin");
const path = require("path");

// Good resource:
// https://www.valentinog.com/blog/webpack/
// https://survivejs.com/webpack/loading/images/

module.exports = {
  mode: 'development',
  entry: { 
    // If you don't set this, then it will default to main:
    index: path.resolve(__dirname, "src", "index.js"),
    print: path.resolve(__dirname, "src", "print.js")
  },
  output: { 
    filename: "[name]-bundle.js",
    path: path.resolve(__dirname, './dist'),
    publicPath: "/"
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: path.resolve(__dirname, "src", "index.html")
    }),
  ],
  module: {
    rules: [
      {
        test: /\.(png|jpe?g|gif|ico)$/i,
        type: "asset/resource",
        generator: {
          filename: 'images/[name]-[hash:4][ext]'
        },
      },
      {
        test: /\.html$/,
        use: [
          // {
          //   loader: "file-loader",
          //   options: {
          //     name: "[name].[ext]"
          //   }
          // },
          // {
          //   loader: "extract-loader",
          //   options: {
          //     publicPath: "../"
          //   }
          // },
          {
            loader: "html-loader"
          }
        ]
      },
      // {
      //   test: /\.(html)$/i,
      //   type: "asset/resource",
      //   generator: {
      //     filename: '[name][ext]'
      //   },
      // },
      {
        test: /\.css$/,
        use: [{ loader: "style-loader" }, { loader: "css-loader" }]//, { loader: "postcss-loader" }]
      },
      {
        test: /\.scss$/,
        use: [
          { loader: "style-loader" },
          { loader: "css-loader" },
          { loader: "sass-loader" }
        ]
      },
      {
        test: /\.js$/,
        use: [{ loader: "swc-loader" }],
        exclude: /(node_modules|bower_components)/
      } 
    ]
  }
};