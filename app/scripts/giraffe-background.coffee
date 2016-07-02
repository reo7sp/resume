$ = require 'jquery-slim'


withGiraffe = null

reInit = ->
  wasWithKitten = withGiraffe
  withGiraffe = $(document).width() > 640
  if wasWithKitten != withGiraffe
    if withGiraffe
      $('.giraffe-background_mobile').remove()
      $(document.body).append '<img class="giraffe-background giraffe-background_giraffe" src="images/giraffe.png">'
      $(document.body).append '<div class="giraffe-background giraffe-background_dialog">Hi there</div>'
      $(document.body).append '<div class="giraffe-background giraffe-background_back" src="images/background.jpg"></div>'
    else
      $('.giraffe-background_giraffe').remove()
      $('.giraffe-background_dialog').remove()
      $('.giraffe-background_back').remove()
      $(document.body).append '<img class="giraffe-background giraffe-background_mobile" src="images/giraffe-mobile.jpg">'
  return

moveGiraffe = (percentX, percentY) ->
  giraffe = $('.giraffe-background_dialog')
  giraffe.css('right', "#{150 + percentX * 120}px")
  giraffe.css('top', "#{250 + -percentY * 40}px")

  giraffe = $('.giraffe-background_giraffe')
  giraffe.css('right', "#{percentX * 50}px")
  giraffe.css('bottom', "#{-15 + percentY * 15}px")

  sky = $('.giraffe-background_back')
  sky.css('background-position', "#{-50 + -percentX * 20}px #{-50 + -percentY * 4}px")
  return


$(document).mousemove (e) ->
  if withGiraffe
    percentX = e.clientX / $(window).width()
    percentY = e.clientY / $(window).height()
    moveGiraffe percentX, percentY

$(window).resize ->
  reInit()

$(document).ready ->
  reInit()
  if withGiraffe
    moveGiraffe 0, 0
