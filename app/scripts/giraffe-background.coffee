$ = require 'jquery-slim'


width = null
height = null
isWithGiraffe = null
giraffeHiText = null

reInit = ->
  width = $(window).width()
  height = $(window).height()
  wasWithGiraffe = isWithGiraffe
  isWithGiraffe = width > 992
  if wasWithGiraffe != isWithGiraffe
    if isWithGiraffe
      $('.giraffe-background_mobile').remove()
      $(document.body).append('<img class="giraffe-background giraffe-background_giraffe" src="images/giraffe.png">')
      $(document.body).append('<div class="giraffe-background giraffe-background_dialog">' + giraffeHiText + '</div>')
      $(document.body).append('<div class="giraffe-background giraffe-background_back" src="images/background.jpg"></div>')
    else
      $('.giraffe-background_giraffe').remove()
      $('.giraffe-background_dialog').remove()
      $('.giraffe-background_back').remove()
      $(document.body).append('<img class="giraffe-background giraffe-background_mobile" src="images/giraffe-mobile.jpg">')

moveGiraffe = (percentX, percentY) ->
  dialog = $('.giraffe-background_dialog')
  dialog.css('right', "#{100 + percentX * 140}px")
  dialog.css('top', "#{250 + -percentY * 75}px")

  giraffe = $('.giraffe-background_giraffe')
  giraffe.css('right', "#{-50 + percentX * 50}px")
  giraffe.css('bottom', "#{-25 + percentY * 25}px")

  back = $('.giraffe-background_back')
  back.css('background-position', "#{-50 + -percentX * 20}px #{-50 + -percentY * 5}px")


$(document).mousemove (e) ->
  if isWithGiraffe
    percentX = e.clientX / width
    percentY = e.clientY / height
    moveGiraffe(percentX, percentY)

$(window).resize ->
  reInit()

$ ->
  giraffeHiText = $('#giraffe-hi-text').text()
  reInit()
  if isWithGiraffe
    moveGiraffe(0, 0)

