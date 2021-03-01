# frozen_string_literal: true

RSpec.describe Webpack5::Builder::WebpackJsonFactory do
  let(:webpack1) do
    described_class.webpack
  end
  let(:webpack2) do
    described_class.webpack
  end

  let(:root_scope1) do
    described_class.root_scope
  end
  let(:root_scope2) do
    described_class.root_scope do |root|
      root.require_webpack = true
    end
  end

  let(:entry1) do
    described_class.entry(:main)
  end
  let(:entry2) do
    described_class.entry do |root|
      root.require_webpack = true
    end
  end

  def p(title, _hash)
    puts 70 * '-'
    puts title
    puts 70 * '-'
  end

  fit { puts JSON.pretty_generate(webpack1.as_json) }
  fit { puts JSON.pretty_generate(root_scope1.as_json) }
  # fit { puts JSON.pretty_generate(webpack1.as_json) }

  describe '#root_scope' do
    context 'default root scope' do
      subject { root_scope1 }

      it { is_expected.to be_a(Webpack5::Builder::JsonData) }

      it {
        expect(subject).to have_attributes(
          require_path: true,
          require_webpack: false,
          require_mini_css_extract_plugin: false,
          require_html_webpack_plugin: false,
          require_workbox_webpack_plugin: false,
          require_autoprefixer: false,
          require_precss: false
        )
      }
    end

    context 'altered root scope' do
      subject { root_scope2 }

      it {
        expect(subject).to have_attributes(
          require_path: true,
          require_webpack: true,
          require_mini_css_extract_plugin: false,
          require_html_webpack_plugin: false,
          require_workbox_webpack_plugin: false,
          require_autoprefixer: false,
          require_precss: false
        )
      }
    end
  end
end
