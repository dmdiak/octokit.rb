require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'octokit'
require 'rspec'
require 'webmock/rspec'

WebMock.disable_net_connect!(:allow => 'coveralls.io')

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.order = :default
end

require 'vcr'
VCR.configure do |c|
  # TODO: Strip authorization header to hide tokens
  c.filter_sensitive_data("<GITHUB_LOGIN>") do
      ENV['OCTOKIT_TEST_GITHUB_LOGIN']
  end
  c.filter_sensitive_data("<GITHUB_PASSWORD>") do
      ENV['OCTOKIT_TEST_GITHUB_PASSWORD']
  end
  c.default_cassette_options = {
    :serialize_with             => :syck,
    :decode_compressed_response => true,
    :record                     => ENV['TRAVIS'] ? :none : :new_episodes
  }
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end

def test_github_login
  ENV.fetch 'OCTOKIT_TEST_GITHUB_LOGIN'
end

def test_github_password
  ENV.fetch 'OCTOKIT_TEST_GITHUB_PASSWORD'
end

def stub_delete(url)
  stub_request(:delete, github_url(url))
end

def stub_get(url)
  stub_request(:get, github_url(url))
end

def stub_head(url)
  stub_request(:head, github_url(url))
end

def stub_patch(url)
  stub_request(:patch, github_url(url))
end

def stub_post(url)
  stub_request(:post, github_url(url))
end

def stub_put(url)
  stub_request(:put, github_url(url))
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def json_response(file)
  {
    :body => fixture(file),
    :headers => {
      :content_type => 'application/json; charset=utf-8'
    }
  }
end

def github_url(url)
  url =~ /^http/ ? url : "https://api.github.com#{url}"
end

def basic_github_url(path, options = {})
  login = options.fetch(:login, test_github_login)
  password = options.fetch(:password, test_github_password)

  "https://#{login}:#{password}@api.github.com#{path}"
end

def basic_auth_client(login = test_github_login, password = test_github_password )
  client = Octokit.client
  client.login = test_github_login
  client.password = test_github_password

  client
end

