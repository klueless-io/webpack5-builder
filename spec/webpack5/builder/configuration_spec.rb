# frozen_string_literal: true

RSpec.describe Webpack5::Builder::Configuration do
  let(:builder_module) { Webpack5::Builder }

  after :each do
    builder_module.reset
  end

  describe '.npm_package_groups' do
    subject { builder_module.configuration.npm_package_groups }

    context 'when not configured' do
      it { is_expected.to eq({}) }
    end

    context 'when custom configured' do
      before :each do
        builder_module.configure do |config|
          config.set_package_group('custom', 'Webpack V4', %w[webpack@4 webpack-cli webpack-dev-server])
        end
      end

      it {
        expect(subject['custom']).to have_attributes(key: 'custom',
                                                     description: 'Webpack V4',
                                                     package_names: %w[webpack@4 webpack-cli webpack-dev-server])
      }
    end

    context 'when configured with default package groups' do
      before :each do
        builder_module.configure(&:default_package_groups)
      end

      it { expect(subject.keys).to have_attributes(count: 4).and include('webpack', 'swc', 'babel', 'typescript') }
      it {
        expect(subject['webpack']).to have_attributes(key: 'webpack',
                                                      description: 'Webpack V5',
                                                      package_names: %w[webpack webpack-cli webpack-dev-server])
      }

      context 'and custom package_groups' do
        before :each do
          builder_module.configure do |config|
            config.set_package_group('webpack4', 'Webpack V4', %w[webpack@4 webpack-cli webpack-dev-server])
          end
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
        before :each do
          builder_module.configure do |config|
            config.set_package_group('webpack', 'Webpack V4', %w[webpack@4 webpack-cli webpack-dev-server])
          end
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
