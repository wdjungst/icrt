class ICRT < Sinatra::Application
  enable :sessions
  @@rooms = { :MULTICS => "instructure.com_3336383934393632323839@resource.calendar.google.com", :HURD => "instructure.com_35353435363634322d353735@resource.calendar.google.com",
             :MINIX => "instructure.com_2d3433363235383239373538@resource.calendar.google.com", :HP_UX => "instructure.com_34323832363030373531@resource.calendar.google.com",
             :DOS => "instructure.com_2d38353538383937372d353232@resource.calendar.google.com", :BSD => "instructure.com_2d3134383735383530393230@resource.calendar.google.com",
             :Netware => "instructure.com_2d35323436363732342d313434@resource.calendar.google.com", :System1 => "instructure.com_2d35313039343536312d333839@resource.calendar.google.com",
             :Plan9 => "instructure.com_2d35363438313633332d373831@resource.calendar.google.com", :BeOS => "instructure.com_2d34333836313235352d373338@resource.calendar.google.com",
             :AmigaOS => "instructure.com_2d3939343731333536343132@resource.calendar.google.com" }

  @@times = { '30' => 30, '100' => 60, '130' => 90, '200' => 120, '230' => 150, '300' => 180, '330' => 220, '400' => 250  }
  @@end_event = Time.now.in_time_zone('America/Denver')

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
  
  def room_available?(room, time)
    converted_time = @@times[time]
    start_time = Time.now.in_time_zone('America/Denver')
    @@end_event = round_time(start_time + converted_time.minutes)
    freebusy?(room, start_time, @@end_event)
  end

  def closest(n)
    closest_interval = [0, 15, 30, 45, 60].map { |m|
      [m, (m - n).abs]
    }.min_by { |_, minutes_away|
      minutes_away
    }
    closest_interval.first
  end
 
  def round_time(t)
    minutes = t.strftime("%M").to_i
    round_to = closest(minutes)
    if round_to == 60
      time = t.change(:min => 00)
      time += 1.hours
    else
      time = t.change(:min => round_to)
    end
    time
  end

  def freebusy?(room, min_time, max_time)
    result = api_client.execute({
      api_method: settings.calendar.freebusy.query, 
      body: JSON.dump({
          timeMin: min_time.iso8601, 
          timeMax: max_time.iso8601,
          items: [{ id: room}]
      }),
      :authorization => user_credentials,
      headers: {'Content-Type' => 'application/json'}
    })
    result.body.split('busy').last.include?('start') ? 'true' : 'false'
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
    Time.zone = "America/Denver"
    start_time = Time.now.in_time_zone(Time.zone)
    event = { 'summary' => 'STOLEN!', 'start' => { 'dateTime' => "#{start_time.iso8601}" }, 'end' => { 'dateTime' => "#{@@end_event.iso8601}" } } 

    result = api_client.execute(:api_method => settings.calendar.events.insert,
                            :parameters => {'calendarId' => params[:room_id]},
                            :authorization => user_credentials,
                            :body => JSON.dump(event),
                            :headers => {'Content-Type' => 'application/json'})
    halt 400 if result.status != 200
    parsed = JSON.parse(result.data.to_json)
    puts result.data.to_json
    event_id = parsed['id']
    creator = parsed['creator']
    name = creator['displayName']
    email = creator['email']
    "#{event_id},#{@@rooms.key(params[:room_id])},#{start_time.strftime("%I:%M%p")},#{@@end_event.strftime("%I:%M%p")}"
  end
  
  post '/update_event_details' do
    update = { 'summary' => params[:title], 'attendees[]' => params[:attendees] } 
    result = api_client.execute(:api_method => settings.calendar.events.update,
                                 :parameters => {'calendarId' => params[:room], 'eventId' => params[:event_id]},
                                 :authorization => user_credentials,
                                 :body => JSON.dump(update),
                                 :headers => {'Content-Type' => 'applicaiont/json'})
    puts result.to_json
    halt 400 if result.status != 200
  end
end
