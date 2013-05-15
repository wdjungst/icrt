// Generated by CoffeeScript 1.4.0
(function() {

  $(function() {
    var postRooms;
    $('.map').maphilight();
    postRooms = function(rooms) {
      return $.each(rooms, function(i, l) {
        return $.ajax({
          type: "POST",
          url: '/room',
          data: "room=" + ($(l).attr('id')) + "&time=" + ($('#time_select').val()),
          success: function(data) {
            if (data === 'true') {
              return $(l).attr('data-maphilight', '{"fillColor":"228B22","fillOpacity":"0.3", "alwaysOn":true}').trigger("alwaysOn.maphilight");
            } else {
              return $(l).attr('data-maphilight', '{"fillColor":"FF0000","fillOpacity":"0.3", "alwaysOn":true}').trigger("alwaysOn.maphilight");
            }
          },
          error: function(data) {
            console.log('fail');
            return alert(data);
          }
        });
      });
    };
    postRooms($('.room'));
    $('area').bind('click', function(e) {
      e.preventDefault();
      return $.get("/book_room?room_id=" + ($(this).attr('id')), function(response) {
        var values;
        alert(response);
        $('#reserve_modal').modal('show');
        values = response.split(",");
        $('#room_name').val(values[0]);
        return $('#start_time').val(values[1]);
      });
    });
    return $('#time_select').bind('change', function() {
      $('.room').data("maphilight", {
        alwaysOn: false
      }).trigger("alwaysOn.maphilight");
      return postRooms($('.room'));
    });
  });

}).call(this);
