// Generated by CoffeeScript 1.4.0
(function() {

  $(function() {
    var duration, postRooms;
    $('.map').maphilight();
    duration = function() {
      return $.ajax({
        type: "POST",
        url: '/duration',
        data: "time=" + ($('#time_select').val()),
        success: function(data) {
          var times;
          times = data.split(',');
          return $('#duration').html("Showing rooms available from " + times[0] + " to " + times[1]);
        },
        error: function(data) {
          return console.log(data);
        }
      });
    };
    postRooms = function(rooms) {
      duration();
      return $.each(rooms, function(i, l) {
        return $.ajax({
          type: "POST",
          url: '/room',
          data: "room=" + ($(l).attr('id')) + "&time=" + ($('#time_select').val()),
          success: function(data) {
            var $el;
            $el = $(l);
            if (data === 'false') {
              $el.removeClass('not-available');
              if ($el.attr('data-maphilight')) {
                return $el.data("maphilight", {
                  fillColor: "228B22",
                  alwaysOn: true
                }).trigger("alwaysOn.maphilight");
              } else {
                return $el.attr('data-maphilight', '{"fillColor":"228B22","fillOpacity":"0.3", "alwaysOn":true}').trigger("alwaysOn.maphilight");
              }
            } else {
              if ($el.attr('data-maphilight')) {
                return $el.data("maphilight", {
                  fillColor: "FF0000",
                  alwaysOn: true
                }).trigger("alwaysOn.maphilight");
              } else {
                return $el.addClass('not-available').attr('data-maphilight', '{"fillColor":"FF0000","fillOpacity":"0.3", "alwaysOn":true}').trigger("alwaysOn.maphilight");
              }
            }
          },
          error: function(data) {
            return console.log(data);
          }
        });
      });
    };
    postRooms($('.room'));
    $('area').bind('click', function(e) {
      var $area;
      e.preventDefault();
      $area = $(this);
      duration = $('#time_select').val();
      if (!$area.hasClass('not-available')) {
        return $.ajax({
          type: 'POST',
          url: '/book_room',
          data: "room_id=" + ($area.attr('id')) + "&duration=" + duration,
          success: function(data) {
            var event_details;
            event_details = data.split(',');
            return bootbox.dialog("Room Booked!", [
              {
                label: "Modify Event Details",
                id: "book-details",
                callback: function() {
                  $('#event_id').val(event_details[0]);
                  $('#room_name').val(event_details[1]);
                  $('#start_time').val(event_details[2]);
                  $('#end_time').val(event_details[3]);
                  $('#event_title').val(event_details[4]);
                  $('#attendees').val(event_details[5]);
                  return $('#update_modal').modal('show');
                }
              }, {
                label: "Ok",
                id: "book-confirm",
                callback: function() {
                  return postRooms($('.room'));
                }
              }
            ]);
          },
          error: function() {
            return console.log('error');
          }
        });
      }
    });
    $('#update_event').bind('click', function(e) {
      e.preventDefault();
      $.ajax({
        type: 'POST',
        url: '/update_event_details',
        data: $('#update_event_form').serializeArray(),
        success: function(data) {
          $('#update_modal').modal('hide');
          return postRooms($('.room'));
        },
        error: function(data) {
          return $('.error-box').html(data);
        }
      });
      return false;
    });
    $('#cancel_event_update').bind('click', function(e) {
      e.preventDefault();
      return postRooms($('.room'));
    });
    return $('#time_select').bind('change', function() {
      console.log('time select changed');
      $('.room').data("maphilight", {
        alwaysOn: false
      }).trigger("alwaysOn.maphilight");
      return postRooms($('.room'));
    });
  });

}).call(this);
