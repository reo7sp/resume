var gulp = require('gulp');
var gulpPlumber = require('gulp-plumber');
var gulpSass = require('gulp-sass');
var gulpCsso = require('gulp-csso');


gulp.task('css', function() {
    return gulp.src('style.scss').
        pipe(gulpPlumber()).
        pipe(gulpSass()).
        pipe(gulpCsso()).
        pipe(gulp.dest('.'));
});


gulp.task('build', ['css']);

gulp.task('watch', ['build'], function () {
    return gulp.watch('style.scss', ['css']);
});

gulp.task('default', ['build']);
