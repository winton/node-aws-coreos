requireDirectory = require("require-directory")
gulpLoadPlugins  = require("gulp-load-plugins")

# Gulpfile initializer. Straw facilitates gulping.
#
# @example Gulpfile.js
#   require("coffee-script/register");
#
#   var gulp  = require("gulp");
#   var path  = require("path");
#   var Straw = require("node-aws-coreos/lib/straw");
#
#   new Straw(gulp, path.resolve("tasks"));
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
  # @param [String] @tasks_path path to gulp tasks directory
  #
  constructor: (@gulp, @tasks_path) ->
    @silenced     = []
    @plugins      = gulpLoadPlugins()
    @tasks        = requireDirectory(module, @tasks_path)
    @vendor_tasks = requireDirectory(module, 'tasks')

    for tasks in [ @vendor_tasks, @tasks ]
      fn(@gulp, @plugins, @) for task, fn of tasks

    if @silenced.indexOf(process.argv[2]) > -1
      @turnOffGulpOutput()

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
    @gulp.task(task, fn)

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
  turnOnGulpOutput: ->
    console.log = @log if @log

module.exports = Straw