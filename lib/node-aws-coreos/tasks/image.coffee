Docker = require("./docker")

module.exports = (gulp, $, straw) ->

  gulp.task "image", ->
    Docker.Image.build()

  straw.silentTask "image:command", ->
    console.log [
      Docker.Image.commands.rmi
      Docker.Image.commands.build
    ].join "; "