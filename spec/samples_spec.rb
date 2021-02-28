# frozen_string_literal: true

RSpec.describe 'Samples' do
  let(:builder_module) { Webpack5::Builder }
  let(:folder) { File.join(Dir.getwd, '.samples', subfolder) }
  let(:config) { Webpack5::Builder.configuration }
  let(:context) { Webpack5::Builder::Context.new(config) }
  let(:package_builder) { Webpack5::Builder::PackageBuilder.new(context) }
  let(:cfg) { ->(config) {} }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  fit 'runs a template' do
    puts Handlebars::Helpers::Template.render('{{camel .}}', 'david was here')
    puts Handlebars::Helpers::Template.render('{{dasherize .}}', 'david was here')
  end

  describe 'create package for transpiler swc' do
    let(:cfg) do
      lambda { |config|
        config.target_folder = folder
        config.default_package_groups
      }
    end

    let(:subfolder) { '01-transpiler-swc' }

    # Samples need to use rspec-usage
    it 'run' do
      # package_builder
      #   .npm_init
      #   .add_file('.gitignore', template_file: 'web-project/.gitignore' )
      #   .vscode
      #   package_builder
      #     .npm_init
      #     .set('description', 'Transpiler SWC using Webpack 5')
      #     .remove_script('test')
      #     .add_script('transpile', 'npx swc src -d dist')
      #     .add_script('run', 'node dist/index.js')
      #     .add_file('.gitignore', template_file: 'web-project/.gitignore')
      #     .add_file('src/index.js', content: <<~JAVASCRIPT
      #       // test nullish coalescing - return right side when left side null or undefined
      #       const x = null ?? "default string";
      #       console.assert(x === "default string");

      #       const y = 0 ?? 42;
      #       console.assert(y === 0);
      #     JAVASCRIPT
      #     )
      #     .development
      #     .npm_add_group('swc')
      #     .vscode
    end
  end
end
