$ ->
  postRooms = (rooms) ->
    for room in rooms
      $.ajax
        type: "POST"
        url: '/room'
        data: "room=#{$(room).attr('id')}&time=#{$('#time_select').val()}"
        success: (data) ->
          console.log('success')
          alert(data)
        error: (data) ->
          console.log('fail')
          alert(data)
  
  postRooms($('.room'))

  $('area').bind 'click', (e) ->
    e.preventDefault()
    # figure out how to redirect to google cal with the correct room and time

  $('#time_select').bind 'change', ->
    postRooms($('.room'))

  $('area').hover ->
    #if color is red set disabled attr and class on area
    console.log("hovered on " + $(@).attr('id'))
