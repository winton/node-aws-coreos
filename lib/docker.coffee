fs = require "fs"

# Namespace for Docker classes. Also stores `.docker` configuration.
#
class Docker
  
  # Parsed `.docker` configuration JSON.
  #
  @config: JSON.parse(
    fs.readFileSync("#{process.cwd()}/.docker", "utf8")
  )

  # @return [String] docker image name
  # @example
  #   Docker.image() # image
  #
  @image: -> @config.repo.split("/").pop()

  # @return [String] full docker repo path
  # @example
  #   Docker.repo() # quay.io/user/image
  #
  @repo:  -> @config.repo

  # Runs a container.
  #
  # @param [String] name name of container (see [Docker.Args](Docker/Args.html))
  #
  @run:   (name) -> new Docker.Container(name).run()

require("./docker/api")(Docker)
require("./docker/args")(Docker)
require("./docker/container")(Docker)
require("./docker/image")(Docker)

module.exports = Docker