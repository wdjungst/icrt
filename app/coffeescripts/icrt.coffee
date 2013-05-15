$ ->
  $('.map').maphilight()
  
  postRooms = (rooms) ->
    $.each rooms, (i, l) ->
      $.ajax
        type: "POST"
        url: '/room'
        data: "room=#{$(l).attr('id')}&time=#{$('#time_select').val()}"
        success: (data) ->
          if data == 'true'
            $(l).attr('data-maphilight','{"fillColor":"228B22","fillOpacity":"0.3", "alwaysOn":true}').trigger "alwaysOn.maphilight"
          else
            $(l).attr('data-maphilight','{"fillColor":"FF0000","fillOpacity":"0.3", "alwaysOn":true}').trigger "alwaysOn.maphilight"
        error: (data) ->
          console.log('fail')
          alert(data)
  postRooms($('.room'))

  $('area').bind 'click', (e) ->
    e.preventDefault()
    $.get "/book_room?room_id=#{$(@).attr('id')}&duration=#{$('#time_select').val()}", (response) ->
      $('#reserve_modal').modal('show')
      values = response.split(",")
      $('#room_name').val(values[0])
      $('#start_time').val(values[1])
      $('#end_time').val(values[2])
      
  $('#time_select').bind 'change', ->
    $('.room').data("maphilight",
        alwaysOn: false
    ).trigger "alwaysOn.maphilight"
    postRooms($('.room'))
