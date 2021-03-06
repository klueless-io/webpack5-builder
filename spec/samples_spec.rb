# frozen_string_literal: true

RSpec.describe 'Samples' do
  let(:builder_module) { Webpack5::Builder }
  let(:folder) { File.join(Dir.getwd, '.samples', subfolder) }
  let(:config) { Webpack5::Builder.configuration }
  let(:context) { Webpack5::Builder::Context.new(config) }
  let(:package_builder) { Webpack5::Builder::PackageBuilder.new(context) }
  let(:webpack_builder) { Webpack5::Builder::WebpackBuilder.new(context) }
  let(:cfg) { ->(config) {} }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  describe 'webpack samples' do
    let(:cfg) do
      lambda { |config|
        config.target_folder = folder
        config.default_package_groups
      }
    end

    context 'webpack_init only' do
      let(:subfolder) { '01-a-empty-config' }

      before do
        webpack_builder
          .webpack_init
          .add_file('webpack.config.js',
                    pretty: true,
                    template_file: 'webpack.config.js.txt',
                    **webpack_builder.webpack_rc.as_json)
        # .vscode
      end

      # it {}
    end

    context 'devserver' do
      context 'opinionated' do
        let(:subfolder) { '02-a-devserver-opinion' }

        before do
          webpack_builder
            .webpack_init
            .webpack_dev_server
            .add_file('webpack.config.js',
                      template_file: 'webpack.config.js.txt',
                      pretty: true,
                      **webpack_builder.webpack_rc.as_json)
          # .vscode
        end

        # it {}
      end
      context 'custom' do
        let(:subfolder) { '02-a-devserver-custom' }

        before do
          webpack_builder
            .webpack_init
            .webpack_dev_server do |o|
              o.xxx = 'xxx'
            end
            .add_file('webpack.config.js',
                      template_file: 'webpack.config.js.txt',
                      pretty: true,
                      **webpack_builder.webpack_rc.as_json)
          # .vscode
        end

        # it {}
      end
    end

    context 'mode' do
      context 'opinionated' do
        let(:subfolder) { '05-a-mode-opinion' }

        before do
          webpack_builder
            .webpack_init
            .mode
            .add_file('webpack.config.js',
                      template_file: 'webpack.config.js.txt',
                      pretty: true,
                      **webpack_builder.webpack_rc.as_json)
            .vscode
        end

        # it {}
        # fit { webpack_builder.vscode.pause }
      end
      context 'custom' do
        let(:subfolder) { '05-a-mode-custom' }

        before do
          webpack_builder
            .webpack_init
            .mode do |o|
              o.mode = './src/main.js'
            end
            .add_file('webpack.config.js',
                      template_file: 'webpack.config.js.txt',
                      pretty: true,
                      **webpack_builder.webpack_rc.as_json)
          # .vscode
        end

        # it {}
      end
    end

    context 'entry' do
      context 'opinionated' do
        let(:subfolder) { '03-a-entry-opinion' }

        before do
          webpack_builder
            .webpack_init
            .entry
            .add_file('webpack.config.js',
                      template_file: 'webpack.config.js.txt',
                      pretty: true,
                      **webpack_builder.webpack_rc.as_json)
          # .vscode
        end

        # need expectation that the files are (json) default and config.js (blank)
        # it {}
      end
      context 'custom' do
        let(:subfolder) { '03-a-entry-custom' }

        before do
          webpack_builder
            .webpack_init
            .entry do |o|
              o.entry = './src/main.js'
            end
            .add_file('webpack.config.js',
                      template_file: 'webpack.config.js.txt',
                      pretty: true,
                      **webpack_builder.webpack_rc.as_json)
          # .vscode
        end

        # it {}
      end
    end

    context 'entries' do
      context 'opinionated' do
        let(:subfolder) { '04-a-entries-opinion' }

        before do
          webpack_builder
            .webpack_init
            .entries
            .add_file('webpack.config.js',
                      template_file: 'webpack.config.js.txt',
                      pretty: true,
                      **webpack_builder.webpack_rc.as_json)
          # .vscode
        end

        # need expectation that the files are (json) default and config.js (blank)
        # it {}
      end
      context 'custom' do
        let(:subfolder) { '04-a-entries-custom' }

        before do
          webpack_builder
            .webpack_init
            .entries do |o|
            o.entries = {
              home: './src/main.js',
              about: './src/about.js',
              contact: './src/contact.js'
            }
          end
            .add_file('webpack.config.js',
                      template_file: 'webpack.config.js.txt',
                      pretty: true,
                      **webpack_builder.webpack_rc.as_json)
          # .vscode
        end

        # it {}
      end
    end

    context 'plugin_mini_css_extract' do
      context 'opinionated' do
        let(:subfolder) { '06-a-plugin_mini_css_extract-opinion' }

        before do
          webpack_builder
            .webpack_init
            .plugin_mini_css_extract
            .add_file('webpack.config.js',
                      template_file: 'webpack.config.js.txt',
                      pretty: true,
                      **webpack_builder.webpack_rc.as_json)
          # .vscode
        end

        # need expectation that the files are (json) default and config.js (blank)
        # it {}
      end
      context 'custom' do
        let(:subfolder) { '06-a-plugin_mini_css_extract-custom' }

        before do
          webpack_builder
            .webpack_init
            .plugin_mini_css_extract do |o|
              o.filename = 'xmen.[contenthash].css'
            end
            .add_file('webpack.config.js',
                      template_file: 'webpack.config.js.txt',
                      pretty: true,
                      **webpack_builder.webpack_rc.as_json)
          # .vscode
        end

        # it {}
      end
    end

    context 'complete' do
      let(:subfolder) { '30-complete-webpack' }

      before do
        # webpack_builder
        #   .webpack_init
        #   .vscode

        webpack_builder
          .webpack_init
          .mode
          .webpack_dev_server
          .entries
          .plugin_mini_css_extract
          .plugin_mini_css_extract do |o|
            o.filename = 'xmen.[contenthash].css'
          end

        webpack_builder.add_file('webpack.config.js',
                                 pretty: true,
                                 template_file: 'webpack.config.js.txt',
                                 **webpack_builder.webpack_rc.as_json)
      end

      # .plugin_mini_css_extract
      # .entries

      # .entries
      # .entries do |o|
      #   o.entries = {
      #     home: './src/main.js',
      #     about: './src/about.js',
      #     contact: './src/contact.js'
      #   }
      # end

      # it {}
    end
  end

  # describe 'create webpack.config.js for transpiler swc' do
  describe 'create package.json for transpiler swc' do
    let(:cfg) do
      lambda { |config|
        config.target_folder = folder
        config.default_package_groups
      }
    end

    let(:subfolder) { '20-package-transpiler-swc' }

    before do
      # package_builder
      #   .npm_init
      #   .vscode

      package_builder
        .npm_init
        .set('description', 'Transpiler SWC using Webpack 5')
        .remove_script('test')
        .add_script('transpile', 'npx swc src -d dist')
        .add_script('run', 'node dist/index.js')
        .add_file('.gitignore', template_file: 'web-project/.gitignore')
        .add_file('src/index.js', content: <<~JAVASCRIPT
          // test nullish coalescing - return right side when left side null or undefined
          const x = null ?? "default string";
          console.assert(x === "default string");

          console.log('x will be: ', x);
          const y = 0 ?? 42;
          console.assert(y === 0);

          console.log('y will be: ', y);
        JAVASCRIPT
        )
        .development
        .npm_install_group('swc')
        .npm_install('bs')
    end

    # it {}

    # Samples need to use rspec-usage
  end
end
