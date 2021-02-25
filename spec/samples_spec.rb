# frozen_string_literal: true

RSpec.describe 'Samples' do
  let(:builder_module) { Webpack5::Builder }
  let(:folder) { File.join(Dir.getwd, '.samples', subfolder) }

  describe 'create package for transpiler swc' do
    before :each do
      builder_module.configure do |config|
        config.target_folder = folder
        config.default_package_groups
      end
    end
    after :each do
      builder_module.reset
    end
    let(:subfolder) { '01-simple-init' }

    it 'run' do
      config = Webpack5::Builder.configuration
      context = Webpack5::Builder::Context.new(config)
      package = Webpack5::Builder::PackageBuilder.new(context)

      puts package.output_path

      package.init
    end
  end
end
