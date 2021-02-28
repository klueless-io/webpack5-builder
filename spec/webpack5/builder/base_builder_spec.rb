# frozen_string_literal: true

RSpec.describe Webpack5::Builder::BaseBuilder do
  include_context :use_temp_folder

  let(:builder_module) { Webpack5::Builder }
  let(:folder) { File.join(@temp_folder, subfolder) }
  let(:subfolder) { '01-base-builder' }
  let(:config) { Webpack5::Builder.configuration }
  let(:context) { Webpack5::Builder::Context.new(config) }
  let(:builder) { described_class.new(context) }
  let(:cfg) do
    lambda { |config|
      config.target_folder = folder
    }
  end

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  describe '#output_path' do
    subject { builder.output_path }
    it { is_expected.not_to be_empty }
  end

  describe '#target_file' do
    subject { builder.target_file(file) }

    let(:file) { 'some_file.txt' }

    it { is_expected.to eq(File.join(builder.output_path, file)) }
  end

  describe '#template_path' do
    subject { builder.template_path }
    it { is_expected.not_to be_empty }
  end

  describe '#template_file' do
    subject { builder.template_file(file) }

    let(:file) { 'some_file.txt' }

    it { is_expected.to eq(File.join(builder.template_path, file)) }
  end
end
