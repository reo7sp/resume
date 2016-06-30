gulp = require 'gulp'
$ = require('gulp-load-plugins')()

fs = require 'fs'
_ = require 'lodash'

del = require 'del'
runSequence = require 'run-sequence'
browserSync = require 'browser-sync'

browserify = require 'browserify'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'


# --- Utils --- #
file_exists = (file) ->
  try
    fs.statSync(file).isFile()
  catch
    false


plumberOptions =
  errorHandler: (err) ->
    $.util.beep()
    $.util.log(
      $.util.colors.cyan('Plumber') + $.util.colors.red(' found unhandled error:\n'),
      err.toString()
    )
    this.emit("end")


# --- Styles --- #
stylesMain = _.find ['app/styles/main.sass', 'app/styles/main.scss', 'app/styles/main.css'], file_exists
stylesMain ?= 'app/styles/main.sass'
styles = 'app/styles/**/*.{sass,scss,css}'

stylesPipe = ->
  gulp.src stylesMain
    .pipe $.plumber plumberOptions
    .pipe $.sourcemaps.init()
    .pipe $.sass.sync()
    .pipe $.rename 'app.css'
    .pipe $.autoprefixer()

gulp.task 'styles', ->
  stylesPipe()
    .pipe $.sourcemaps.write '.'
    .pipe gulp.dest '.tmp/styles'

gulp.task 'styles:dist', ->
  cssnanoOptions =
    discardComments:
      removeAll: true

  stylesPipe()
    .pipe $.cssnano(cssnanoOptions)
    .pipe gulp.dest 'dist/styles'


# --- Scripts --- #
scriptsMain = _.find ['app/scripts/main.coffee', 'app/scripts/main.js'], file_exists
scriptsMain ?= 'app/scripts/main.coffee'
scripts = 'app/scripts/**/*.{coffee,js}'

scriptsPipe = ->
  browserify scriptsMain, {debug: true}
    .transform 'coffeeify'
    .bundle()
    .on 'error', plumberOptions.errorHandler
    .pipe source 'app.js'
    .pipe buffer()
#    .pipe $.plumber plumberOptions

gulp.task 'scripts', ->
  scriptsPipe()
    .pipe $.sourcemaps.init {loadMaps: true}
    .pipe $.sourcemaps.write '.'
    .pipe gulp.dest '.tmp/scripts'

gulp.task 'scripts:dist', ->
  scriptsPipe()
    .pipe $.uglify()
    .pipe gulp.dest 'dist/scripts'


# --- HTMLs --- #
htmls = ['app/**/*.html', '!app/**/_*.html']

htmlsPipe = ->
  gulp.src htmls
    .pipe $.plumber plumberOptions
    .pipe $.nunjucksRender {path: 'app'}

gulp.task 'htmls', ->
  htmlsPipe()
    .pipe gulp.dest '.tmp'

gulp.task 'htmls:dist', ->
  htmlminOptions =
    removeComments: true
    collapseWhitespace: true
    collapseBooleanAttributes: true
    removeAttributeQuotes: true
    removeRedundantAttributes: true
    removeEmptyAttributes: true
    removeScriptTypeAttributes: true
    removeStyleLinkTypeAttributes: true
    removeOptionalTags: true

  htmlsPipe()
    .pipe $.htmlmin htmlminOptions
    .pipe gulp.dest 'dist'


# --- Images --- #
images = 'app/images/**/*'

imagesPipe = ->
  gulp.src images
    .pipe $.plumber plumberOptions

gulp.task 'images', ->
  imagesPipe()
    .pipe $.cached 'images'
    .pipe gulp.dest '.tmp/images'

gulp.task 'images:dist', ->
  imagesPipe()
    .pipe $.cached 'images:dist'
    .pipe $.imagemin({progressive: true, interlaced: true})
    .pipe gulp.dest 'dist/images'


#
sourcesTasks = ['styles', 'scripts', 'htmls', 'images']
sourcesFileGroups = [styles, scripts, htmls, images]
sources = _.flattenDeep(sourcesFileGroups)
everything = 'app/**/*'


# --- Other --- #
other = _.concat everything, _.map(sources, (match) -> "#{if match[0] != '!' then '!' else ''}#{match}")

otherPipe = ->
  gulp.src other
    .pipe $.plumber plumberOptions
    .pipe gulp.dest('dist')

gulp.task 'other', ->
  otherPipe()

gulp.task 'other:dist', ->
  otherPipe()


#
allSourcesTasks = _.concat sourcesTasks, 'other'
allSourcesDistTasks = _.map allSourcesTasks, (task) -> "#{task}:dist"
allSourcesFileGroups = _.concat sourcesFileGroups, [other]


# --- Main --- #
gulp.task 'clean', ->
  del ['.tmp', 'dist/*'], {dot: true}

gulp.task 'compile', allSourcesTasks

gulp.task 'compile:dist', allSourcesDistTasks

gulp.task 'serve', ['compile'], ->
  browserSync {notify: false, server: ['.tmp', 'dist']}
  for [name, group] in _.zip allSourcesTasks, allSourcesFileGroups
    gulp.watch group, [name, browserSync.reload]
  return

gulp.task 'serve:dist', ['compile:dist'], ->
  browserSync {notify: false, server: ['dist']}
  for [name, group] in _.zip allSourcesDistTasks, allSourcesFileGroups
    gulp.watch group, [name, browserSync.reload]
  return

gulp.task 'build', (callback) ->
  runSequence 'clean', 'compile', callback
  
gulp.task 'build:dist', (callback) ->
  runSequence 'clean', 'compile:dist', callback

gulp.task 'deploy', ['build:dist'], ->
  surgeOptions =
    project: './dist'
    domain: 'www.reo7sp.ru'

  $.surge surgeOptions

gulp.task 'default', ['build:dist']
