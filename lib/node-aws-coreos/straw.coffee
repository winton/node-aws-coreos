gulp = require("gulp")

# Gulpfile initializer. Straw facilitates gulping.
#
# @example Gulpfile.js
#   require('coffee-script/register');
#   Straw = require('./lib/straw.coffee');
#   new Straw();
#
# @example tasks/clean.coffee
#   module.exports = (gulp, plugins, straw) ->
#     gulp.task "clean", ->
#       gulp
#         .src([ ".sass-cache", ".tmp", "dist" ], read: false)
#         .pipe plugins.clean()
#
class Straw

  # Load plugins and gulp tasks. Silence gulp if necessary.
  #
  constructor: ->
    @silenced = []
    @plugins  = require("gulp-load-plugins")()
    @tasks    = require("require-directory")(module, '../tasks')

    fn(gulp, @plugins, @) for task, fn of @tasks

    if @silenced.indexOf(process.argv[2]) > -1
      @turnOffGulpOutput()

  # List the directories in `/dist`.
  #
  # @return [Array<String>] directory names
  #
  @distDirectories: ->
    src   = "#{process.cwd()}/src"
    dists = fs.readdirSync(src).filter (file) ->
      fs.lstatSync("#{src}/#{file}").isDirectory()

  # Silences gulp output, while still allowing `console.log` from tasks.
  #
  # @param [String] task task name to silence gulp output for
  #
  silence: (task) ->
    @silenced.push task

  # Shortcut for `gulp.task` that silences gulp output.
  #
  # @param [String] task task name
  # @param [Function] fn task function
  #
  silentTask: (task, fn) ->
    @silence(task)
    gulp.task(task, fn)

  # Turn off gulp console output.
  #
  turnOffGulpOutput: ->
    @log = console.log

    console.log = =>
      args = Array::slice.call(arguments)
      return if args.length && /^\[/.test(args[0])
      @log.apply console, args

  # Turn on gulp console output.
  #
  turnOffGulpOutput: ->
    console.log = @log if @log

module.exports = Straw