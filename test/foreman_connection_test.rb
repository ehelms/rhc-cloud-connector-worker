# frozen_string_literal: true

require 'test_helper'

class ForemanConnectionTest < Minitest::Test
  def test_passes_params_to_rh_cloud_cloud_request
    test_metadata = {
      'foo' => 'bar'
    }
    stub_request(:post, 'https://example.com/api/v2/rh_cloud/cloud_request').with(
      body: test_metadata,
      basic_auth: %w[TEST_USER TEST_TOKEN]
    ).to_return(status: 200, body: '', headers: {})

    foreman = RhcCloudConnectorWorker::Foreman.new(
      address: 'https://example.com',
      require_ssl: false,
      ssl_ca_file: 'foo.pem',
      token: 'TEST_TOKEN',
      user: 'TEST_USER'
    )

    foreman.pass(test_metadata)
  end
end
