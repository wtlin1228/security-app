# frozen_string_literal: true

require_relative './spec_helper'
require 'webmock/minitest'

describe 'Test Service Objects' do
  before do
    @credentials = { username: 'soumya.ray', password: 'mypa$$w0rd' }
    @mal_credentials = { username: 'soumya.ray', password: 'anyolepassword' }
    @api_account = { account:
                       { username: 'soumya.ray', email: 'sray@nthu.edu.tw' } }

    WebMock.stub_request(:post, "#{API_URL}/accounts/authenticate")
           .with(body: @credentials.to_json)
           .to_return(body: @api_account.to_json,
                      headers: { 'content-type' => 'application/json' })

    WebMock.stub_request(:post, "#{API_URL}/accounts/authenticate")
           .with(body: @mal_credentials.to_json)
           .to_return(status: 403)
  end

  describe 'Find authenticated account' do
    it 'HAPPY: should find an authenticated account' do
      account = FindAuthenticatedAccount.new(app.config).call(@credentials)
      _(account).wont_be_nil
      _(account['username']).must_equal @api_account[:account][:username]
      _(account['email']).must_equal @api_account[:account][:email]
    end

    it 'BAD: should not find a false authenticated account' do
      account = FindAuthenticatedAccount.new(app.config).call(@mal_credentials)
      _(account).must_be_nil
    end
  end
end
