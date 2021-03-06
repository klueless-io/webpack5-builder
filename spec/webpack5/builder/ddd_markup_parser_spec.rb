# frozen_string_literal: true

RSpec.describe Webpack5::Builder::DddMarkupParser do
  let(:instance) { described_class.new }
  let(:file) { '/Users/davidcruwys/dev/c#/P04DomainMonopolyV1/README_.md' }

  before do
    instance.parse_file(file)
  end

  it {
    instance.parse
  }
end
