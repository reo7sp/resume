$ = require 'jquery-slim'


$ ->
  $('a').each ->
    classes = $(this).attr('class') ? ''
    href = $(this).attr('href')
    return unless href?

    isHrefRelative = href.indexOf('http') != 0 && !(href.indexOf('skype:') == 0 || href.indexOf('mailto:') == 0)

    title = href
      .replace('www.', '')
      .replace('skype:', '')
      .replace('?add', '')
      .replace('mailto:', '')

    if isHrefRelative
      title = 'https://reo7sp.ru/' + title

    $(this).after(
      '<a ' +
      'class="printable-link ' + classes + '" ' +
      'href="' + href + '"' +
      '>' + title + '</a>'
    )
    $(this).addClass('not-printable-link')