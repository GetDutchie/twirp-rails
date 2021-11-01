# frozen_string_literal: true

RSpec.describe Twirp::Rails::Configuration do
  describe '#handlers_path' do
    subject { config.handlers_paths }

    let(:config) { described_class.new }

    before do
      config.add_handlers_path('app/controllers/rpc')
      config.add_handlers_path('app/rpc')
    end
    it { is_expected.to eq ["app/controllers/rpc", "app/rpc"] }
  end
end
