$ ->
  $('area').bind 'click', (e) ->
    e.preventDefault()
    alert("clicked on " + $(@).attr('id'))

  $('area').hover ->
    console.log("hovered on " + $(@).attr('id'))
