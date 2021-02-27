# frozen_string_literal: true

# RSpec.describe 'Samples' do
#   let(:builder_module) { Webpack5::Builder }
#   let(:folder) { File.join(Dir.getwd, '.samples', subfolder) }
#   let(:config) { Webpack5::Builder.configuration }
#   let(:context) { Webpack5::Builder::Context.new(config) }
#   let(:builder) { Webpack5::Builder::PackageBuilder.new(context) }
#   let(:cfg) { ->(config) {} }

#   before :each do
#     builder_module.configure(&cfg)
#   end
#   after :each do
#     builder_module.reset
#   end

#   describe 'create package for transpiler swc' do
#     before :each do
#       builder_module.configure do |config|
#         config.target_folder = folder
#         config.default_package_groups
#       end
#     end
#     after :each do
#       builder_module.reset
#     end
#     let(:subfolder) { '01-simple-init' }

#     it 'run' do
#       puts builder.output_path
#       puts builder.package

#       # builder.init
#     end
#   end
# end
