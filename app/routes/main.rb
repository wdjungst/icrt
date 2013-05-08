require 'rubygems'
require 'google/api_client'
require 'logger'
#require 'open-uri'
#require 'net/https'

#module Net
#  class HTTP
#    alias_method :original_use_ssl=, :use_ssl=
#
#    def use_ssl=(flag)
#      if File.exists?('/etc/ssl/certs')
#        self.ca_path = '/etc/ssl/certs'
#      elsif File.exists?('/opt/local/share/curl/curl-ca-bundle.crt')
#        self.ca_file = '/opt/local/share/curl/curl-ca-bundle.crt'
#      end
#
#      self.verify_mode = OpenSSL::SSL::VERIFY_PEER
#      self.original_use_ssl = flag
#    end
#  end
#end

class ICRT < Sinatra::Application
  enable :sessions

  def loger; settings.logger end

  def api_client; setting.api_client; end

  def calendar_api; settings.calendar; end

  def user_credentials
    @authorization ||= (
      auth = api_cleint.authorize.dup
      auth.redirect_uri = to('/oauth2callback')
      auth.update_token!(session)
      auth
   )
  end
  
  configure do
    log_file = File.open('calendar.log', 'a+')
    log_file.sync = true
    logger = Logger.new(log_file)
    logger.level = Logger::DEBUG

    client = Google::APIClient.new
    # Generate client id and secret here https://code.google.com/p/google-apps-manager/wiki/GettingAnOAuthConsoleKey
    client.authorization.client_id = '...'
    client.authorization.client_secret = '...'
    client.authorization.scope = 'https://www.googleapis.com/auth/calendar'

    calendar = client.discovered_api('calendar', 'v3')

    set :logger, logger
    set :api_client, client
    set :calendar, calendar

  end

  before do
    unless user_credentials.access_token || request.path_info =~ /^\/oath2/
      redirect to('/oauth2authorize')
    end
  end

  after do
    session[:access_token] = user_credentials.access_token
    session[:refresh_token] = user_credentials.refresh_token
    session[:expires_in] = user_credentials.expires_in
    session[:issued_at] = user_credentials.issued_at
  end

  get '/oauth2authorize' do
    redirect user_credentials.authorization_uri.to_s, 303
  end

  get '/oauth2callback' do
    user_credentials.code = params[:code] if params[:code]
    user_credentials.fetch_access_token!
    redirect to('/')
  end

  get '/' do
    haml :index
  end

  post '/room/:name' do |name|
    # do google stuff on that name
  end
end
