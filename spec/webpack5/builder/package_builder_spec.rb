# frozen_string_literal: true

# Warning: I am not using mocks and so there is a known test anti
#          I am aware that this is an Anti Pattern in unit testing
#          but I am sticking with this pattern for now as it saves
#          me a lot of time in writing tests.
# Future:  May want to remove this Anti Pattern
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

  # Yallist & Boolbase are two NPM packages with minimal dependencies
  let(:yallist) { 'yallist' }
  let(:node_target_yallist) { File.join(builder.output_path, 'node_modules', 'yallist') }
  let(:boolbase) { 'boolbase' }
  let(:node_target_boolbase) { File.join(builder.output_path, 'node_modules', 'boolbase') }
  let(:multiple_packages) { [yallist, boolbase] }

  before :each do
    builder_module.configure(&cfg)
  end

  after :each do
    builder_module.reset
  end

  describe '.output_path' do
    subject { builder.output_path }
    it { is_expected.not_to be_empty }
  end

  describe '.package_file' do
    subject { builder.package_file }
    it { is_expected.not_to be_empty }
  end

  describe '.package' do
    subject { builder.package }

    it { expect(-> { subject }).to raise_error Webpack5::Builder::Error, 'package.json does not exist' }
  end

  # Driven of dependency_type, this will be -D or -P for NPM
  describe '.dependency_option' do
    subject { builder.dependency_option }

    it { is_expected.to eq('-D') }

    context 'change to production dependency' do
      before { builder.production }

      it { is_expected.to eq('-P') }
    end
  end

  describe '#npm_init' do
    before :each do
      builder.npm_init
    end

    describe '#package_file' do
      subject { builder.package_file }

      it { is_expected.to eq(File.join(folder, 'package.json')) }
    end

    describe '#package' do
      subject { builder.package }

      it { is_expected.to include('name' => '01-simple-init') }
    end
  end

  describe '#parse_options' do
    subject { builder.parse_options(options).join(' ') }
    let(:options) { nil }

    context 'when nil' do
      it { is_expected.to be_empty }
    end

    context 'when empty string' do
      let(:options) { '' }
      it { is_expected.to be_empty }
    end

    context 'when multiple options' do
      let(:options) { '-a -B --c' }
      it { is_expected.to eq('-a -B --c') }
    end

    context 'when multiple options wit extra spacing' do
      let(:options) { '-abc     -xyz' }
      it { is_expected.to eq('-abc -xyz') }
    end

    context 'with required_options' do
      subject { builder.parse_options(options, required_options).join(' ') }

      let(:options) { '-a     -b' }
      let(:required_options) { nil }

      context 'when nil' do
        it { is_expected.to eq('-a -b') }
      end

      context 'when empty string' do
        let(:required_options) { '' }
        it { is_expected.to eq('-a -b') }
      end

      context 'when add required option' do
        let(:required_options) { '-req-option' }
        it { is_expected.to eq('-a -b -req-option') }
      end

      context 'when add existing and required options' do
        let(:required_options) { '-req1   -b  -req2 -a' }
        it { is_expected.to eq('-a -b -req1 -req2') }
      end
    end
  end

  describe '#npm_install' do
    context 'when options are configured via builder' do
      subject { builder.package }

      before :each do
        builder.npm_init
               .production
               .npm_install(boolbase)
               .development
               .npm_install(yallist)
      end

      it do
        expect(Dir.exist?(node_target_yallist)).to be_truthy
        expect(Dir.exist?(node_target_boolbase)).to be_truthy

        is_expected
          .to  have_key('dependencies')
          .and include('dependencies' => { 'boolbase' => a_value })
          .and have_key('devDependencies')
          .and include('devDependencies' => { 'yallist' => a_value })
      end
    end

    context 'when two packages are supplied manually' do
      subject { builder.package }
      before :each do
        builder.npm_init
               .npm_install(multiple_packages, options: options)
      end

      context 'development' do
        let(:options) { '-D' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_truthy
          expect(Dir.exist?(node_target_boolbase)).to be_truthy

          is_expected
            .to  have_key('devDependencies')
            .and include('devDependencies' => { 'yallist' => a_value, 'boolbase' => a_value })
        end
      end
    end

    context 'when options are supplied manually' do
      subject { builder.package }

      before :each do
        builder.npm_init
               .npm_install(yallist, options: options)
      end

      context 'install dependency' do
        context 'development' do
          let(:options) { '-D' }

          it do
            expect(Dir.exist?(node_target_yallist)).to be_truthy

            is_expected.to have_key('devDependencies')
              .and include('devDependencies' => { 'yallist' => a_value })
          end
        end

        context 'production' do
          let(:options) { '-P' }

          it do
            expect(Dir.exist?(node_target_yallist)).to be_truthy

            is_expected.to have_key('dependencies')
              .and include('dependencies' => { 'yallist' => a_value })
          end
        end
      end
    end
  end

  describe '#npm_add' do
    # adds dependency, but does not install
    subject { builder.package }

    context 'when options are configured via builder' do
      before :each do
        builder.npm_init
               .production
               .npm_add(boolbase)
               .development
               .npm_add(yallist)
      end

      it do
        expect(Dir.exist?(node_target_yallist)).to be_falsey
        expect(Dir.exist?(node_target_boolbase)).to be_falsey

        is_expected
          .to  have_key('dependencies')
          .and include('dependencies' => { 'boolbase' => a_value })
          .and have_key('devDependencies')
          .and include('devDependencies' => { 'yallist' => a_value })
      end
    end

    context 'when options are supplied manually' do
      before :each do
        builder.npm_init
               .npm_add(yallist, options: options)
      end

      context 'development' do
        let(:options) { '-D' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_falsey

          is_expected.to have_key('devDependencies')
            .and include('devDependencies' => { 'yallist' => a_value })
        end
      end

      context 'production' do
        let(:options) { '-P' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_falsey

          is_expected.to have_key('dependencies')
            .and include('dependencies' => { 'yallist' => a_value })
        end
      end
    end
  end

  describe '#npm_add_group' do
    # adds dependency, but does not install
    subject { builder.package }

    let(:cfg) do
      lambda { |config|
        config.target_folder = folder
        config.default_package_groups
        config.set_package_group('xmen', 'Sample Packages', multiple_packages)
      }
    end

    context 'when options are configured via builder' do
      before :each do
        builder.npm_init
               .production
               .npm_add_group('xmen')
      end

      it do
        expect(Dir.exist?(node_target_yallist)).to be_falsey
        expect(Dir.exist?(node_target_boolbase)).to be_falsey

        is_expected
          .to  have_key('dependencies')
          .and include('dependencies' => { 'boolbase' => a_value, 'yallist' => a_value })
      end
    end

    context 'when options are supplied manually' do
      before :each do
        builder.npm_init
               .npm_add_group('xmen', options: options)
      end

      context 'development' do
        let(:options) { '-D' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_falsey
          expect(Dir.exist?(node_target_yallist)).to be_falsey

          is_expected
            .to have_key('devDependencies')
            .and include('devDependencies' => { 'yallist' => a_value, 'boolbase' => a_value })
        end
      end
    end
  end

  describe '#npm_install_group' do
    subject { builder.package }

    let(:cfg) do
      lambda { |config|
        config.target_folder = folder
        config.default_package_groups
        config.set_package_group('xmen', 'Sample Packages', multiple_packages)
      }
    end

    context 'when options are configured via builder' do
      before :each do
        builder.npm_init
               .production
               .npm_install_group('xmen')
      end

      it do
        expect(Dir.exist?(node_target_yallist)).to be_truthy
        expect(Dir.exist?(node_target_boolbase)).to be_truthy

        is_expected
          .to  have_key('dependencies')
          .and include('dependencies' => { 'boolbase' => a_value, 'yallist' => a_value })
      end
    end

    context 'when options are supplied manually' do
      before :each do
        builder.npm_init
               .npm_install_group('xmen', options: options)
      end

      context 'development' do
        let(:options) { '-D' }

        it do
          expect(Dir.exist?(node_target_yallist)).to be_truthy
          expect(Dir.exist?(node_target_yallist)).to be_truthy

          is_expected
            .to have_key('devDependencies')
            .and include('devDependencies' => { 'yallist' => a_value, 'boolbase' => a_value })
        end
      end
    end
  end
end
