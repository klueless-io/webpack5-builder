# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Webpack5::Builder::Configuration do
  let(:builder_module) { Webpack5::Builder }
  let(:temp_folder) { Dir.mktmpdir('my-webpack-project') }
  let(:cfg) { ->(config) {} }

  before :each do
    builder_module.configure(&cfg)
  end
  after :each do
    builder_module.reset
  end

  describe '.target_folder' do
    subject { builder_module.configuration.target_folder }

    context 'when not configured' do
      it { is_expected.to eq('') }
    end

    context 'when configured' do
      let(:cfg) do
        lambda { |config|
          config.target_folder = temp_folder
        }
      end

      it { is_expected.to eq(temp_folder) }
    end
  end

  describe '.template_folder' do
    subject { builder_module.configuration.template_folder }

    context 'when not configured' do
      it { is_expected.to eq(File.join(Dir.getwd, '.template')) }
    end

    context 'when configured' do
      let(:cfg) do
        lambda { |config|
          config.template_folder = '/some-folder'
        }
      end

      it { is_expected.to eq('/some-folder') }
    end
  end

  describe '.package_groups' do
    subject { builder_module.configuration.package_groups }

    context 'when not configured' do
      it { is_expected.to eq({}) }
    end

    context 'when custom configured' do
      let(:cfg) do
        lambda { |config|
          config.set_package_group('custom', 'Webpack V4', %w[webpack@4 webpack-cli webpack-dev-server])
        }
      end

      it {
        expect(subject['custom']).to have_attributes(key: 'custom',
                                                     description: 'Webpack V4',
                                                     package_names: %w[webpack@4 webpack-cli webpack-dev-server])
      }
    end

    context 'when configured with default package groups' do
      let(:cfg) do
        lambda { |config|
          config.default_package_groups
        }
      end

      it { expect(subject.keys).to have_attributes(count: 4).and include('webpack', 'swc', 'babel', 'typescript') }
      it {
        expect(subject['webpack']).to have_attributes(key: 'webpack',
                                                      description: 'Webpack V5',
                                                      package_names: %w[webpack webpack-cli webpack-dev-server])
      }

      context 'and custom package_groups' do
        let(:cfg) do
          lambda { |config|
            config.default_package_groups
            config.set_package_group('webpack4', 'Webpack V4', %w[webpack@4 webpack-cli webpack-dev-server])
          }
        end

        it { expect(subject.keys).to have_attributes(count: 5).and include('webpack4', 'webpack', 'swc', 'babel', 'typescript') }

        it {
          expect(subject['webpack4']).to have_attributes(key: 'webpack4',
                                                         description: 'Webpack V4',
                                                         package_names: %w[webpack@4 webpack-cli webpack-dev-server])
        }

        it {
          expect(subject['webpack']).to have_attributes(key: 'webpack',
                                                        description: 'Webpack V5',
                                                        package_names: %w[webpack webpack-cli webpack-dev-server])
        }
      end

      context 'and overrides an existing package_group' do
        let(:cfg) do
          lambda { |config|
            config.default_package_groups
            config.set_package_group('webpack', 'Webpack V4', %w[webpack@4 webpack-cli webpack-dev-server])
          }
        end

        it { expect(subject.keys).to have_attributes(count: 4).and include('webpack', 'swc', 'babel', 'typescript') }

        it {
          expect(subject['webpack']).to have_attributes(key: 'webpack',
                                                        description: 'Webpack V4',
                                                        package_names: %w[webpack@4 webpack-cli webpack-dev-server])
        }
      end
    end
  end
end
