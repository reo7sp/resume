# Based on https://github.com/reo7sp/reo-web-starter-kit
gulp = require "gulp"
$ = require("gulp-load-plugins")()

fs = require "fs"
_ = require "lodash"
del = require "del"
runSequence = require "run-sequence"
browserSync = require "browser-sync"
browserify = require "browserify"
browserifyInc = require "browserify-incremental"
source = require "vinyl-source-stream"
buffer = require "vinyl-buffer"
sassyNpmImporter = require "sassy-npm-importer"


sourceRoot         = "app"
stylesSourceRoot   = "#{sourceRoot}/styles"
scriptsSourceRoot  = "#{sourceRoot}/scripts"
htmlSourceRoot     = sourceRoot
imagesSourceRoot   = "#{sourceRoot}/images"

tmpDistRoot        = ".tmp"
stylesTmpDistRoot  = "#{tmpDistRoot}/styles"
scriptsTmpDistRoot = "#{tmpDistRoot}/scripts"
htmlTmpDistRoot    = tmpDistRoot
imagesTmpDistRoot  = "#{tmpDistRoot}/images"

distRoot           = "dist"
stylesDistRoot     = "#{distRoot}/styles"
scriptsDistRoot    = "#{distRoot}/scripts"
htmlDistRoot       = distRoot
imagesDistRoot     = "#{distRoot}/images"


# --- Utils --- #
file_exists = (file) ->
  try
    fs.statSync(file).isFile()
  catch
    false


plumberOptions =
  errorHandler: $.notify.onError("<%= error.message %>")


# --- Styles --- #
possibleStylesMain = ["#{stylesSourceRoot}/main.sass", "#{stylesSourceRoot}/main.scss", "#{stylesSourceRoot}/main.css"]
stylesMain = _.find(possibleStylesMain, file_exists)
stylesMain ?= possibleStylesMain[0]
styles = "#{stylesSourceRoot}/**/*.{sass,scss,css}"

stylesPipe = ->
  gulp.src stylesMain
    .pipe $.plumber(plumberOptions)
    .pipe $.sourcemaps.init()
    .pipe $.sass.sync(importer: sassyNpmImporter())
    .pipe $.rename("app.css")
    .pipe $.autoprefixer()

gulp.task "styles:dev", ->
  stylesPipe()
    .pipe $.sourcemaps.write(".")
    .pipe gulp.dest stylesTmpDistRoot

gulp.task "styles:dist", ->
  stylesPipe()
    .pipe $.csso(comments: false)
    .pipe $.rev()
    .pipe gulp.dest stylesDistRoot
    .pipe $.rev.manifest(merge: true)
    .pipe gulp.dest "."


# --- Scripts --- #
possibleScriptsMain = ["#{scriptsSourceRoot}/main.coffee", "#{scriptsSourceRoot}/main.js"]
scriptsMain = _.find(possibleScriptsMain, file_exists)
scriptsMain ?= possibleScriptsMain[0]
scripts = "#{scriptsSourceRoot}/**/*.{coffee,js}"

scriptsPipe = ->
  b = browserify(scriptsMain, _.extend(browserifyInc.args, debug: true))
  browserifyInc(b, cacheFile: "./browserify-cache.json")
  b
    .transform("coffeeify")
    .bundle()
    .on("error", plumberOptions.errorHandler)
    .pipe source("app.js")
    .pipe buffer()

gulp.task "scripts:dev", ->
  scriptsPipe()
    .pipe $.sourcemaps.init(loadMaps: true)
    .pipe $.sourcemaps.write(".")
    .pipe gulp.dest scriptsTmpDistRoot

gulp.task "scripts:dist", ->
  scriptsPipe()
    .pipe $.uglify()
    .pipe $.rev()
    .pipe gulp.dest scriptsDistRoot
    .pipe $.rev.manifest(merge: true)
    .pipe gulp.dest "."


# --- HTMLs --- #
htmls = "#{htmlSourceRoot}/**/*.{html,njk}"
htmlsWithoutPartials = ["#{htmlSourceRoot}/**/*.html", "!#{htmlSourceRoot}/**/_*.html"]

htmlsPipe = ->
  gulp.src htmlsWithoutPartials
    .pipe $.plumber(plumberOptions)
    .pipe $.nunjucksRender(path: htmlSourceRoot)

gulp.task "htmls:dev", ->
  htmlsPipe()
    .pipe $.cached("htmls")
    .pipe gulp.dest htmlTmpDistRoot

gulp.task "htmls:dist", ->
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
    .pipe $.cached("htmls:dist")
    .pipe $.revReplace(manifest: gulp.src("./rev-manifest.json"))
    .pipe $.htmlmin(htmlminOptions)
    .pipe gulp.dest htmlDistRoot


# --- Images --- #
images = "#{imagesSourceRoot}/**/*"

imagesPipe = ->
  gulp.src images
    .pipe $.plumber(plumberOptions)

gulp.task "images:dev", ->
  imagesPipe()
    .pipe $.cached("images")
    .pipe gulp.dest imagesTmpDistRoot

gulp.task "images:dist", ->
  imagesPipe()
    .pipe $.cached("images:dist")
    .pipe $.imagemin(progressive: true, interlaced: true)
    .pipe gulp.dest imagesDistRoot


#
sourcesTasks = ["styles", "scripts", "htmls", "images"]
sourcesFileGroups = [styles, scripts, htmls, images]
sources = _.flattenDeep(sourcesFileGroups)
everything = "#{sourceRoot}/**/*"


# --- Other --- #
other = _.concat(everything, _.map(sources, (match) -> "#{if match[0] != "!" then "!" else ""}#{match}"))

otherPipe = ->
  gulp.src other
    .pipe $.plumber(plumberOptions)
    .pipe $.cached("other")
    .pipe gulp.dest distRoot

gulp.task "other:dev", ->
  otherPipe()

gulp.task "other:dist", ->
  otherPipe()


#
allSourcesTasks = _.concat(sourcesTasks, "other")
allSourcesDevTasks = _.map(allSourcesTasks, (task) -> "#{task}:dev")
allSourcesDistTasks = _.map(allSourcesTasks, (task) -> "#{task}:dist")
allSourcesFileGroups = _.concat(sourcesFileGroups, [other])


# --- Main --- #
gulp.task "clean", ->
  del([tmpDistRoot, "#{distRoot}/*", "rev-manifest.json"], dot: true)

gulp.task "compile:dev", allSourcesDevTasks

gulp.task "compile:dist", (callback) ->
  runSequence _.without(allSourcesDistTasks, "htmls:dist"), "htmls:dist", callback # hack for gulp-rev plugin

gulp.task "watch", ["compile:dev"], ->
  for [name, group] in _.zip allSourcesDevTasks, allSourcesFileGroups
    gulp.watch group, [name]
  return

gulp.task "serve", ["compile:dev"], ->
  browserSync(notify: false, server: [tmpDistRoot, distRoot])
  for [name, group] in _.zip allSourcesDevTasks, allSourcesFileGroups
    gulp.watch group, [name, browserSync.reload]
  return

gulp.task "watch:dist", ["compile:dist"], ->
  for [name, group] in _.zip(allSourcesDistTasks, allSourcesFileGroups)
    gulp.watch group, [name]
  return

gulp.task "serve:dist", ["compile:dist"], ->
  browserSync(notify: false, server: [distRoot])
  for [name, group] in _.zip(allSourcesDistTasks, allSourcesFileGroups)
    gulp.watch group, [name, browserSync.reload]
  return

gulp.task "build:dev", (callback) ->
  runSequence "clean", "compile:dev", callback

gulp.task "build:dist", (callback) ->
  runSequence "clean", "compile:dist", callback

gulp.task "deploy", ["build:dist"], ->
  publisher = $.awspublish.create(require("./aws-config.coffee"))

  gulp.src "#{distRoot}/**/*"
    .pipe publisher.publish()
    .pipe publisher.cache()
    .pipe publisher.sync()
    .pipe $.awspublish.reporter()

gulp.task "default", ["build:dist"]
