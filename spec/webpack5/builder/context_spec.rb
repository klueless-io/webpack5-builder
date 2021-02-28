# frozen_string_literal: true

RSpec.describe Webpack5::Builder::Context do
  let(:builder_module) { Webpack5::Builder }
  let(:temp_folder) { Dir.mktmpdir('my-webpack-project') }
  let(:cfg) do
    lambda { |config|
      config.target_folder = temp_folder
      config.default_package_groups
    }
  end
  let(:context) { described_class.new(builder_module.configuration) }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  describe 'initialize from config' do
    describe '.target_folder' do
      subject { context.target_folder }
      it { is_expected.to eq(temp_folder) }

      context 'change target_folder' do
        before { context.target_folder = '/different/folder' }

        it { is_expected.to eq('/different/folder') }

        context 'config remains untouched' do
          subject { context.config.target_folder }

          it { is_expected.to eq(temp_folder) }
        end
      end
    end

    describe '.template_folder' do
      subject { context.template_folder }
      it { is_expected.to eq(File.join(Dir.getwd, '.template')) }

      context 'change template_folder' do
        before { context.template_folder = '/different/folder' }

        it { is_expected.to eq('/different/folder') }

        context 'config remains untouched' do
          subject { context.config.template_folder }

          it { is_expected.to eq(File.join(Dir.getwd, '.template')) }
        end
      end
    end

    describe '.package_groups' do
      subject { context.package_groups }
      it { expect(subject.keys).to have_attributes(count: 4).and include('webpack', 'swc', 'babel', 'typescript') }

      context 'change package_groups' do
        before do
          context.set_package_group('custom', 'Custom', [])
          context.set_package_group('webpack', 'Altered', [])
        end

        it { expect(subject.keys).to have_attributes(count: 5).and include('webpack', 'swc', 'babel', 'typescript', 'custom') }
        it {
          expect(subject['webpack']).to have_attributes(key: 'webpack',
                                                        description: 'Altered',
                                                        package_names: [])
        }

        context 'config remains untouched' do
          subject { context.config.package_groups }

          it { expect(subject.keys).to have_attributes(count: 4).and include('webpack', 'swc', 'babel', 'typescript') }
        end
      end
    end
  end
end
