require 'rubygems'
require 'google/api_client'

class ICRT < Sinatra::Application
  
  get '/' do
    haml :index
  end

  post '/room/:name' do |name|
    # do google stuff on that name
  end
end
