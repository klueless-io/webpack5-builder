# frozen_string_literal: true

RSpec.describe Webpack5::Builder::PackageBuilder do
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
    }
  end

  # Open package in VSCode
  # builder.rc "code #{builder.package_file}"

  before :each do
    builder_module.configure(&cfg)
  end

  after :each do
    builder_module.reset
  end

  describe '#output_path' do
    subject { builder.output_path }
    it { is_expected.not_to be_empty }
    it { is_expected.not_to be_empty }
  end

  describe '#package_file' do
    subject { builder.package_file }
    it { is_expected.not_to be_empty }
  end

  describe '#package' do
    subject { builder.package }

    it { expect(-> { subject }).to raise_error Webpack5::Builder::Error, 'package.json does not exist' }
  end

  describe '#init' do
    before :each do
      puts "OUTPUT FOLDER: #{builder.output_path}"
      puts "OUTPUT PACKAGE: #{builder.package_file}"
      builder.init
    end

    describe '#package_file' do
      subject { builder.package_file }

      fit { is_expected.to eq(File.join(folder, 'package.json')) }
    end

    describe '#package' do
      subject { builder.package }

      it { is_expected.to include('name' => '01-simple-init') }
    end
  end

  describe '#npm_install' do
    # Yet Another Linked List is an NPM package with minimal dependencies
    let(:packages) { 'yallist' }

    before :each do
      builder.init
      builder.npm_install(packages, options: options)
    end

    context 'create development dependency' do
      subject { builder.package }
      let(:options) { '-D' }

      it do
        is_expected.to have_key('devDependencies')
          .and include('devDependencies' => { 'yallist' => a_value })
      end
    end

    context 'create production dependency' do
      subject { builder.package }
      let(:options) { '-P' }

      it do
        is_expected.to have_key('dependencies')
          .and include('dependencies' => { 'yallist' => a_value })
      end
    end
  end
end
