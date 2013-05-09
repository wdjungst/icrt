// Generated by CoffeeScript 1.6.2
(function() {
  $(function() {
    var postRooms;
    postRooms = function(rooms) {
      return $.each(rooms, function(i, l) {
        return $.ajax({
          type: "POST",
          url: '/room',
          data: "room=" + ($(l).attr('id')) + "&time=" + ($('#time_select').val()),
          success: function(data) {
            if (data === 'true') {
              $(l).attr('data-maphilight', '{"fillColor":"228B22","fillOpacity":"0.6", "alwaysOn":true}');
            } else {
              $(l).attr('data-maphilight', '{"fillColor":"FF0000","fillOpacity":"0.6", "alwaysOn":true}');
            }
            return $('.map').maphilight();
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
      return e.preventDefault();
    });
    return $('#time_select').bind('change', function() {
      return postRooms($('.room'));
    });
  });

}).call(this);
