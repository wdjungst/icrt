require 'rubygems'
require 'sinatra'
require 'yaml'
require 'haml'
require 'rack/contrib'

class ICRT < Sinatra::Application
  set :public_folder, 'public', File.dirname(__FILE__)
  set :root, 'app', File.dirname(__FILE__)
  set :js_path, 'public/javascripts'
  set :jus_url, '/javascripts'
  set :enviornment, :production

  require_relative 'app/routes/init'
end
