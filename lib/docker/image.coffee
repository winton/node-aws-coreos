spawn = require "../spawn"

module.exports = (Docker) -> 

  # Builds image from Dockerfile.
  #
  class Docker.Image

    # Removes image and rebuilds it.
    #
    # @return [Promise<String,Number>] the output and exit code
    #
    @build: ->
      spawn(@commands.rmi).then ->
        spawn(@commands.build, stdio: "inherit")

    @commands:
      rmi:   "docker rmi #{Docker.image()}"
      build: "docker build -t #{Docker.repo()} ."