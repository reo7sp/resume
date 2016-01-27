gulp     = require "gulp"
plugins  = require("gulp-load-plugins")()

srcCss   = "css/**"
srcJs    = "js/**"
srcHtml  = "*.html"
srcImg   = "img/**"
srcOther = "*.@(xml|txt|ico)"

dst      = "bin"

gulp.task "css", ->
	gulp.src srcCss
		.pipe plugins.cached "css"
		.pipe plugins.less()
		.pipe plugins.autoprefixer()
		.pipe plugins.minifyCss()
		.pipe plugins.remember "css"
		.pipe plugins.concat "style.css"
		.pipe gulp.dest dst
		.pipe plugins.livereload()

gulp.task "js", ->
	gulp.src srcJs
		.pipe plugins.concat "app.js"
		.pipe plugins.coffee()
		.pipe plugins.uglify()
		.pipe gulp.dest dst
		.pipe plugins.livereload()

gulp.task "html", ->
	plugins.nunjucksRender.nunjucks.configure(["template"])
	gulp.src srcHtml
		.pipe plugins.nunjucksRender()
		.pipe plugins.minifyHtml()
		.pipe gulp.dest dst
		.pipe plugins.livereload()

gulp.task "img", ->
	gulp.src srcImg
		.pipe plugins.cached "img"
		.pipe gulp.dest "#{ dst }/img"
		.pipe plugins.remember "img"
		.pipe plugins.livereload()

gulp.task "other", ->
	gulp.src srcOther
		.pipe plugins.cached "other"
		.pipe gulp.dest dst
		.pipe plugins.remember "other"

gulp.task "watch", ->
	plugins.livereload.listen()
	gulp.watch srcCss, [ "css" ]
	gulp.watch srcJs, [ "js" ]
	gulp.watch [ srcHtml, "template/**" ], [ "html" ]
	gulp.watch srcImg, [ "img" ]
	gulp.watch srcOther, [ "other" ]

gulp.task "build", [ "css", "js", "html", "img", "other" ]

gulp.task "default", [ "build", "watch" ]

