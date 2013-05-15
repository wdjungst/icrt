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
    unless area.hasClass('not-available')
      $.get "/book_room?room_id=#{$area.attr('id')}&duration=#{$('#time_select').val()}", (response) ->
        $('#reserve_modal').modal('show')
        values = response.split(",")
        $('#room_name').val(values[0])
        $('#start_time').val(values[1])
        $('#end_time').val(values[2])

  $('#time_select').bind 'change', ->
    console.log 'time select changed'
    $('.room').data("maphilight", alwaysOn: false).trigger "alwaysOn.maphilight"
    postRooms($('.room'))
