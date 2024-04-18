# frozen_string_literal: true

RSpec.describe ThrottledJsonRpcClient do
  it "has a version number" do
    expect(ThrottledJsonRpcClient::VERSION).not_to be nil
  end
end
