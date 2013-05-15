require 'rubygems'
require 'sinatra'
require 'yaml'
require 'haml'
require 'rack/contrib'
require 'google/api_client'
require 'logger'
require 'yaml'
require 'open-uri'
require 'net/https'
require 'pry'
require 'activesupport'

module Net
  class HTTP
    alias_method :original_use_ssl=, :use_ssl=

    def use_ssl=(flag)
      if File.exists?('/etc/ssl/certs')
        self.ca_path = '/etc/ssl/certs'
      elsif File.exists?('/usr/local/Cellar/curl-ca-bundle/1.87/share/ca-bundle.crt')
        self.ca_file = '/usr/local/Cellar/curl-ca-bundle/1.87/share/ca-bundle.crt'
      end

      self.verify_mode = OpenSSL::SSL::VERIFY_PEER
      self.original_use_ssl = flag
    end
  end
end

class ICRT < Sinatra::Application
  CONFIG = YAML::load_file(File.expand_path(File.dirname(__FILE__) + '/config/config.yml'))
  set :public_folder, 'public', File.dirname(__FILE__)
  set :root, 'app', File.dirname(__FILE__)
  set :js_path, 'public/javascripts'
  set :jus_url, '/javascripts'
  set :enviornment, :production

  require_relative 'app/routes/init'
end
