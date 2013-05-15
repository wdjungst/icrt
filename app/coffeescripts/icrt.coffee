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
    $.get "book_room/" + $(@).attr('id'), (response) ->
      alert (response)
    $('#reserve_modal').modal('show')
  $('#time_select').bind 'change', ->
    $('.room').data("maphilight",
        alwaysOn: false
    ).trigger "alwaysOn.maphilight"
    postRooms($('.room'))
