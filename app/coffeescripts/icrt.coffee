$ ->
  disableButtons = (action) ->
    action = '' if typeof action == 'undefined'
    $('.btn').addClass('disabled', action).attr('disabled', action)

  $('.map').maphilight()

  duration = () ->
    $duration = $('#duration')
    $duration.html('Loading Times...')
    $.ajax
      type: "POST"
      url: '/duration'
      data: "time=#{$('#time_select option:selected').val()}"
      success: (data) ->
        times = data.split(',')
        $duration.html("Showing rooms available from #{times[0]} to #{times[1]}")
      error: (data) ->
        console.log(data)

  postRooms = (rooms) ->
    duration()
    room_ids = []
    $.each rooms, (i, l) ->
      room_ids.push($(l).attr('id'))
    $.ajax
      type: "POST"
      url: '/room'
      data: "rooms=#{room_ids}&time=#{$('#time_select option:selected').val()}"
      success: (data) ->
        availableRoomIds = data.split(',')
        $.each rooms, (i, l) ->
          $el = $(l)
          $el.addClass('not-available')
          if $el.attr('data-maphilight')
            $el.data("maphilight", fillColor:"FF0000", alwaysOn:true).trigger "alwaysOn.maphilight"
          else
            $el.attr('data-maphilight','{"fillColor":"FF0000","fillOpacity":"0.3", "alwaysOn":true}').trigger "alwaysOn.maphilight"
        availableRooms = []
        $.each rooms, (roomIndex, room) ->
          if $.inArray($(room).attr('id'), availableRoomIds) > -1
            availableRooms.push(room) 
        $.each availableRooms, (roomIndex, room) ->
          $el = $(room)
          if $el.attr('data-maphilight')
            $el.removeClass('not-available')
            $el.data("maphilight", fillColor: "228B22", alwaysOn: true).trigger "alwaysOn.maphilight"
          else
            $el.removeClass('not-available')
            $el.attr('data-maphilight','{"fillColor":"228B22","fillOpacity":"0.3", "alwaysOn":true}').trigger "alwaysOn.maphilight"
      error: (data) ->
        console.log(data)
  postRooms($('.room'))

  $('area').bind 'click', (e) ->
    e.preventDefault()
    $area = $(@)
    duration = $('#time_select option:selected').val()
    unless $area.hasClass('not-available')
      $.ajax
        type: 'POST',
        url: '/book_room',
        data: "room_id=#{$area.attr('id')}&duration=#{duration}",
        success: (data) ->
          event_details = data.split(',')
          bootbox.dialog "Room Booked!", [
            label: "Update Event Details"
            id: "book-details"
            callback: ->
              $('#event_id').val(event_details[0])
              $('#room_name').val(event_details[1])
              $('#start_time').val(event_details[2])
              $('#end_time').val(event_details[3])
              $('#event_title').val(event_details[4])
              $('#attendees').val(event_details[5])
              $('#update_modal').modal('show')
          ,
            label: "Ok"
            id: "book-confirm"
            callback: ->
              postRooms($('.room'))
          ]
        error: ->
          $('#update_modal').modal('hide')
          postRooms($('.room'))

  $('#update_event').bind 'click', (e) ->
    e.preventDefault()
    disableButtons('disabled')
    $.ajax
      type: 'POST',
      url: '/update_event_details',
      data: $('#update_event_form').serializeArray(),
      success: (data) ->
        $('#update_modal').modal('hide')
        postRooms($('.room'))
      error: (data) ->
        #show error some how

  $('#cancel_event_update').bind 'click', (e) ->
    e.preventDefault()
    postRooms($('.room'))

  $('#settings').bind 'click', (e) ->
    $settings = $(@)
    $timeFrame = $('#time_frame')
    $timeFrame.slideToggle ->
      if $timeFrame.is(':visible')
        $settings.addClass('btn-primary')
      else
        $settings.removeClass('btn-primary')

  $('#time_select').bind 'change', ->
    $('.room').data("maphilight", alwaysOn: false).trigger "alwaysOn.maphilight"
    postRooms($('.room'))

