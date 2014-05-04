gulp = require('gulp')
mocha = require 'gulp-mocha'
coffee = require 'gulp-coffee'

require 'coffee-script/register'

gulp.task 'build', ->
    gulp.src("simplegeneric.litcoffee")
    .pipe coffee()
    #.on 'error', ->gutil.log
    .pipe gulp.dest('.')
    #.pipe filelog()

gulp.task 'test', ['build'], ->
    gulp.src 'spec.litcoffee'
    .pipe mocha
        reporter: "spec"
        #bail: yes
    .on "error", (err) ->
        console.log err.toString()
        console.log err.stack if err.stack?
        @emit 'end'

gulp.task 'default', ['test'], ->
    gulp.watch ['*.litcoffee'], ['test']
