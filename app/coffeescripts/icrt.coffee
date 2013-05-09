$ ->
  postRooms = (rooms) ->
    $.each rooms, (i, l) ->
      $.ajax
        type: "POST"
        url: '/room'
        data: "room=#{$(l).attr('id')}&time=#{$('#time_select').val()}"
        success: (data) ->
          if data == 'true'
            $(l).attr('data-maphilight','{"fillColor":"228B22","fillOpacity":"0.6", "alwaysOn":true}')
          else
            $(l).attr('data-maphilight','{"fillColor":"FF0000","fillOpacity":"0.6", "alwaysOn":true}')
          $('.map').maphilight()
        error: (data) ->
          console.log('fail')
          alert(data)
  postRooms($('.room'))

  $('area').bind 'click', (e) ->
    e.preventDefault()
    # figure out how to redirect to google cal with the correct room and time

  $('#time_select').bind 'change', ->
    postRooms($('.room'))
