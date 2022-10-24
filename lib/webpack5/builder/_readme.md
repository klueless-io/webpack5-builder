# Refactor

Webpack5 builder needs to be broken out into these related packages

- BuildWatcher (as a builder)
- AppBuilder
- BaseBuilder
- WebBuilder
  - PackageBuilder
  - Webpack5Builder
  - ReactBuilder
  - SlideDeckBuilder
  - JavscriptBuilder
- SolutionBuilder
- DotnetBuilder
  - C#Console
  - C#Mvc
- RubyBuilder
  - RubyGem
  - RailsApp
- PythonBuilder
- DddBuilder
  - DddGenerator
