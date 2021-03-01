const path = require("path");
{{#if blueprint.settings.wp_html_plugin}}
const HtmlWebpackPlugin = require("html-webpack-plugin");
{{/if}}
{{#if blueprint.settings.wp_show_resources}}

// Webpack Resources:
// https://www.valentinog.com/blog/webpack/
// https://survivejs.com/webpack/loading/images/
// Typescript Resources
// https://medium.com/jspoint/integrating-typescript-with-webpack-4534e840a02b
// https://medium.com/jspoint/typescript-compilation-the-typescript-compiler-4cb15f7244bc
{{/if}}
{{#if blueprint.settings.wp_html_multi_page}}

// Multi Page Setup
let htmlPages = [
  { name: 'index', title: 'Home'},
  { name: 'example', title: 'Example'}
];
let htmlPlugins = htmlPages.map(page => {
  return new HtmlWebpackPlugin({
    title: page.title,
    template: `./src/${page.name}.html`,
    filename: `${page.name}.html`,
    chunks: [`${page.name}`]
  })
});
{{/if}}

module.exports = {
  mode: 'development',
  {{#if blueprint.settings.wp_rule_transcript}}
  entry: './src/index.ts',
  {{/if}}
  {{#if blueprint.settings.wp_entry}}
  entry: { 
    // If you don't set this, then it will default to main:
    index: path.resolve(__dirname, "src", "index.js"),
    // print: path.resolve(__dirname, "src", "print.js")
  },
  {{/if}}
  {{#if blueprint.settings.wp_rule_transcript}}
  resolve: {
    extensions: ['.tsx', '.ts', '.js'],
  },
  {{/if}}
  {{#if blueprint.settings.wp_output}}
  output: { 
    filename: "[name]-bundle.js",
    path: path.resolve(__dirname, './dist')
  },
  {{/if}}
  {{#if blueprint.settings.wp_html_plugin}}
  plugins: [
    {{#if blueprint.settings.wp_html_plugin}}
      {{#if blueprint.settings.wp_html_multi_page}}
    ...htmlPlugins
      {{else}}
    new HtmlWebpackPlugin({
      template: path.resolve(__dirname, "src", "index.html")
    }),
      {{/if}}
    {{/if}}
  ],
  {{/if}}
  module: {
    rules: [
      {{#if blueprint.settings.wp_rule_image}}
      {
        test: /\.(png|jpe?g|gif|ico)$/i,
        type: "asset/resource",
        generator: {
          filename: 'images/[name]-[hash:4][ext]'
        },
      },
      {{/if}}
      {{#if blueprint.settings.wp_rule_html}}
      {
        test: /\.html$/,
        use: [
          {
            loader: "html-loader"
          }
        ]
      },
      {{/if}}
      {{#if blueprint.settings.wp_rule_css}}
      {
        test: /\.css$/,
        use: [{ loader: "style-loader" }, { loader: "css-loader" }]//, { loader: "postcss-loader" }]
      },
      {{/if}}
      {{#if blueprint.settings.wp_rule_scss}}
      {
        test: /\.scss$/,
        use: [
          { loader: "style-loader" },
          { loader: "css-loader" },
          { loader: "sass-loader" }
        ]
      },
      {{/if}}
      {{#if blueprint.settings.wp_rule_js_swc}}
      {
        test: /\.m?js$/,
        exclude: /(node_modules|bower_components)/,
        use: [{ loader: "swc-loader" }]
      },
      {{/if}}
      {{#if blueprint.settings.wp_rule_js_babel}}
      {
        test: /\.m?js$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      },
      {{/if}}
      {{#if blueprint.settings.wp_rule_transcript}}
      {
        test: /\.tsx?$/,
        use: 'ts-loader',
        exclude: /node_modules/,
      },
      {{/if}}
    ]
  }
};