class ICRT < Sinatra::Application
  enable :sessions
  @@rooms = { :MULTICS => "instructure.com_3336383934393632323839@resource.calendar.google.com", :HURD => "instructure.com_35353435363634322d353735@resource.calendar.google.com",
             :MINIX => "instructure.com_2d3433363235383239373538@resource.calendar.google.com", :HP_UX => "instructure.com_34323832363030373531@resource.calendar.google.com",
             :DOS => "instructure.com_2d38353538383937372d353232@resource.calendar.google.com", :BSD => "instructure.com_2d3134383735383530393230@resource.calendar.google.com",
             :Netware => "instructure.com_2d35323436363732342d313434@resource.calendar.google.com", :System1 => "instructure.com_2d35313039343536312d333839@resource.calendar.google.com",
             :Plan9 => "instructure.com_2d35363438313633332d373831@resource.calendar.google.com", :BeOS => "instructure.com_2d34333836313235352d373338@resource.calendar.google.com",
             :AmigaOS => "instructure.com_2d3939343731333536343132@resource.calendar.google.com" }

  @@times = { '30' => 30, '100' => 60, '130' => 90, '200' => 120, '230' => '150', '300' => '180', '330' => '220', '400' => '250'  }
  
  def loger; settings.logger end

  def api_client; settings.api_client; end

  def calendar_api; settings.calendar; end

  def user_credentials
    @authorization ||= (
      auth = api_client.authorization.dup
      auth.redirect_uri = to('/oauth2callback')
      auth.update_token!(session)
      auth
   )
  end
  
  def validate_response(response)
    if response[2].include? "dateTime" 
      if response[2].include? "cancelled"
        return true
      else 
        return false
      end
    else
      return true
    end
  end

  def room_available?(room, time)
    converted_time = @@times[time]
    puts converted_time
    Time.zone = "America/Denver"
    result = api_client.execute(:api_method => settings.calendar.events.list, 
                                :parameters => {'calendarId' =>"#{room}", 'timeMin' => Time.zone.now.iso8601, 
                                                'timeMax' => (Time.zone.now + converted_time.minutes).iso8601}, 
                                :authorization => user_credentials)

    response = [result.status, {'Content-Type' => 'application/json'}, result.data.to_json]
    puts response[2]
    validate_response(response)
  end

  configure do
    log_file = File.open('calendar.log', 'a+')
    log_file.sync = true
    logger = Logger.new(log_file)
    logger.level = Logger::DEBUG

    client = Google::APIClient.new(
      :application_name => 'icrt',
      :application_version => '1.0'
    )
    client.authorization.client_id = CONFIG['google-api']['client_id']
    client.authorization.client_secret = CONFIG['google-api']['client_secret']
    client.authorization.scope = 'https://www.googleapis.com/auth/calendar'

    calendar = client.discovered_api('calendar', 'v3')

    set :logger, logger
    set :api_client, client
    set :calendar, calendar
  end

  before do
    unless user_credentials.access_token || request.path_info =~ /^\/oauth2/
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

  post '/room' do
    room_available?(params[:room], params[:time].gsub!(':', '')).to_s
  end

  post '/book_room' do
    duration = params[:duration].split(' ').first
    converted_time = @@times[duration]
    end_time = (Time.now.in_time_zone(Time.zone) + converted_time.minutes).strftime("%I:%M%p")
    #make api request to book room
  end

  post '/change_room_details' do
    # get event id and modify the event on  this post action, return an error to the modal if the event can't be changed for some reason
    "#{@@rooms.key(params[:room_id]).to_s},#{Time.now.in_time_zone(Time.zone).strftime("%I:%M%p")},#{end_time}"
  end
end
