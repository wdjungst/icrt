$ ->
  $('.map').maphilight()

  postRooms = (rooms) ->
    $.each rooms, (i, l) ->
      $.ajax
        type: "POST"
        url: '/room'
        data: "room=#{$(l).attr('id')}&time=#{$('#time_select').val()}"
        success: (data) ->
          $el = $(l)
          if data == 'true'
            $el.removeClass('not-available')
            if $el.attr('data-maphilight')
              $el.data("maphilight", fillColor: "228B22", alwaysOn: true).trigger "alwaysOn.maphilight"
            else
              $el.attr('data-maphilight','{"fillColor":"228B22","fillOpacity":"0.3", "alwaysOn":true}').trigger "alwaysOn.maphilight"
          else
            if $el.attr('data-maphilight')
              $el.data("maphilight", fillColor: "FF0000", alwaysOn: true).trigger "alwaysOn.maphilight"
            else
              $el.addClass('not-available').attr('data-maphilight','{"fillColor":"FF0000","fillOpacity":"0.3", "alwaysOn":true}').trigger "alwaysOn.maphilight"
        error: (data) ->
          console.log(data)
  postRooms($('.room'))

  $('area').bind 'click', (e) ->
    e.preventDefault()
    $area = $(@)
    duration = $('#time_select').val()
    unless $area.hasClass('not-available')
      $.ajax
        type: 'POST',
        url: '/book_room',
        data: "room_id=#{$area.attr('id')}&duration=#{duration}",
        success: (data) ->
          event_details = data.split(',')
          bootbox.dialog "Room Booked!", [
            label: "Modify Event Details"
            id: "book-details"
            callback: ->
              $('#event_id').val(event_details[0])
              $('#room_name').val(event_details[1])
              $('#start_time').val(event_details[2])
              $('#end_time').val(event_details[3])
              $('#reserve_modal').modal('show')
          ,
            label: "Ok"
            id: "book-confirm"
            callback: ->
              postRooms($('.room'))
          ]
        error: ->
          #close dialog and requrey rooms to show avai rooms
          console.log('error')

  $('#time_select').bind 'change', ->
    console.log 'time select changed'
    $('.room').data("maphilight", alwaysOn: false).trigger "alwaysOn.maphilight"
    postRooms($('.room'))
