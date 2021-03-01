# frozen_string_literal: true

# Warning: I am not using mocks and so there is a known test anti
#          I am aware that this is an Anti Pattern in unit testing
#          but I am sticking with this pattern for now as it saves
#          me a lot of time in writing tests.
# Future:  May want to remove this Anti Pattern
RSpec.describe Webpack5::Builder::WebpackBuilder do
  include_context :use_temp_folder

  let(:builder_module) { Webpack5::Builder }
  # let(:folder) { File.join(Dir.getwd, '.samples', subfolder) }
  let(:folder) { File.join(@temp_folder, subfolder) }
  let(:subfolder) { '01-simple-init' }
  let(:config) { Webpack5::Builder.configuration }
  let(:context) { Webpack5::Builder::Context.new(config) }
  let(:builder) { described_class.new(context) }
  let(:cfg) do
    lambda { |config|
      config.target_folder = folder
      config.default_package_groups
    }
  end

  # Out of the box, webpack won't require you to use a configuration file.
  # However, it will assume the entry point of your project is src/index.js
  # and will output the result in dist/main.js minified and optimized for production.

  before :each do
    builder_module.configure(&cfg)
  end

  after :each do
    builder_module.reset
  end

  # Will your application have multiple bundles? (y/N) y
  # What do you want to name your bundles? (separated by comma) (pageOne, pageTwo)
  #   - page1,pageTwo,pageThree
  #   - What is the location of "page1"? src/page1
  #   - What is the location of "pageTwo"? src/pageTwo
  #   - What is the location of "pageThree"? src/PageThree/page3
  # In which folder do you want to store your generated bundles? (dist)
  # Will you use one of the below JS solutions? (Use arrow keys)
  # - No
  # - ES6
  # - Typescript
  # Will you use one of the below CSS solutions? (Use arrow keys)
  # - No
  # - CSS
  # - SASS
  # - LESS
  # - PostCSS
  # Will you bundle your CSS files with MiniCssExtractPlugin? (y/N)
  # What will you name the CSS bundle? (main)
  # Do you want to use webpack-dev-server? (Y/n)
  # Do you want to simplify the creation of HTML files for your bundle? (y/N)
  # Do you want to add PWA support? (Y/n)
  #
  #
  #

  fdescribe '.output_path' do
    subject { builder.output_path }
    it { is_expected.not_to be_empty }
    it { puts subject }
  end

  # describe '.webpack_config_file' do
  #   subject { builder.webpack_config_file }
  #   it { is_expected.not_to be_empty }
  # end

  describe '.webpack_rc_file' do
    subject { builder.webpack_rc_file }
    it { is_expected.not_to be_empty }
  end

  describe '.webpack_rc' do
    subject { builder.webpack_rc }
    it { is_expected.to be_empty }
  end

  # fit { puts subject }
  # fit {
  #   subject
  #   builder.vscode
  #   sleep(1)
  # }
end