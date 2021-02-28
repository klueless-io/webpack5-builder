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

  describe '#transform_content' do
    subject { builder.transform_content(**opts) }
    let(:opts) { {} }

    it { is_expected.to be_empty }

    context 'with content' do
      let(:opts) { { content: 'I am content' } }
      it { is_expected.to eq('I am content') }
    end

    context 'with content_file' do
      let(:opts) { { content_file: file.path } }
      let(:file) { Tempfile.new('foo.txt') }

      before do
        file.write 'Content from file'
        file.close
      end
      after { file.unlink }

      it { is_expected.to eq('Content from file') }
    end

    context 'with template' do
      let(:opts) { { template: 'I am content' } }
      it { is_expected.to eq('I am content') }

      context 'and transform values' do
        let(:opts) { { template: 'I am {{dasherize name}}', name: 'david was here' } }
        it { is_expected.to eq('I am david-was-here') }
      end
    end

    context 'with template_file with transform values' do
      let(:opts) { { template_file: 'sample.txt', name: 'david was here' } }
      it do
        is_expected
          .to  include('david-was-here')
          .and include('DavidWasHere')
      end
    end
  end
end
