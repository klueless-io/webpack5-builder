# frozen_string_literal: true

RSpec.describe Webpack5::Builder do
  it 'has a version number' do
    expect(Webpack5::Builder::VERSION).not_to be nil
  end

  it 'has a standard error' do
    expect { raise Webpack5::Builder::Error, 'some message' }
      .to raise_error('some message')
  end
end
