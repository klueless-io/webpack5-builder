# Webpack5 Builder

> Webpack5 Builder provides simple commands for building up package.json and webpack.config for a webpack5 project

As a SPA Developer, I want to configure webpack5 enabled applications quickly, so I don't have to be a WebPack 5 expert.

### Package Builder

The package builder is used exclusively for building the package.json

> It currently has add_file, which will be extracted to the WebProjectBuilder

#### Build package.json for SWC Transpiler

This builder will setup a package.json file with support files for transpiling javascript using the SWC transpiler

```ruby
package_builder
  .npm_init
  .set('description', 'Transpiler SWC using Webpack 5')
  .remove_script('test')
  .add_script('transpile', 'npx swc src -d dist')
  .add_script('run', 'node dist/index.js')
  .add_file('.gitignore', template_file: 'web-project/.gitignore' )
  .add_file('src/index.js', content: <<~JAVASCRIPT
    // test nullish coalescing - return right side when left side null or undefined
    const x = null ?? "default string";
    console.assert(x === "default string");

    const y = 0 ?? 42;
    console.assert(y === 0);
  JAVASCRIPT
  )
  .development
  .npm_add_group('swc')
  .vscode
```

#### Generated package.json

```json
{
  "name": "01-transpiler-swc",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "transpile": "npx swc src -d dist",
    "run": "node dist/index.js"
  },
  "keywords": [],
  "author": "David Cruwys <david@ideasmen.com.au> (https://appydave.com/)",
  "license": "MIT",
  "description": "Transpiler SWC using Webpack 5",
  "devDependencies": {
    "@swc/cli": "^0.1.35",
    "@swc/core": "^1.2.49",
    "swc-loader": "^0.1.12"
  }
}
```

#### Create src/index.js

```javascript
// test nullish coalescing - return right side when left side null or undefined
const x = null ?? "default string";
console.assert(x === "default string");

const y = 0 ?? 42;
console.assert(y === 0);
```

#### Run the transpiler

```bash
npm run transpiler
```

Generated javascript after transpiling

```javascript
var ref;
// test nullish coalescing - return right side when left side null or undefined
var x = (ref = null) !== null && ref !== void 0 ? ref : "default string";
console.assert(x === "default string");
var ref1;
var y = (ref1 = 0) !== null && ref1 !== void 0 ? ref1 : 42;
console.assert(y === 0);
```
