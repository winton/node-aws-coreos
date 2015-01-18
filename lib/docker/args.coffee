os = require "os"

module.exports = (Docker) -> 

  # Generates arguments for Docker CLI and remote API.
  #
  class Docker.Args

    # Initializes a variable holding env variables.
    #
    constructor: (@name, @options={}) ->
      @env  = @options.env || process.env

    # Generates parameters for a Docker remote API call.
    #
    # @return [Object]
    #
    apiParams: ->
      name:  @containerName()
      Cmd:   @commands()
      Image: @image()
      Env:   @envs()
      HostConfig:
        Binds: @binds()
        PortBindings: @portBindings()
      ExposedPorts: @exposedPorts()

    # Generate binds option (which local directories to mount
    # within the container).
    #
    # @return [Object]
    #
    binds: ->
      binds = []
      binds.push(
        "#{@env.APP_PATH || process.cwd()}:/app"
      ) if !@env.ENV || @env.ENV == "development"
      binds.push(
        "#{@env.DOCKER_CERT_PATH}:/certs/docker"
      ) if @env.DOCKER_CERT_PATH
      binds.push(
        "#{@env.DOCKER_SOCKET_PATH}:/var/run/host"
      ) if @env.DOCKER_SOCKET_PATH

      binds

    # Generates parameters for a Docker CLI call.
    #
    # @return [Object]
    #
    cliParams: (options={}) ->
      params = [ "--name", @containerName() ]

      for env in @envs()
        params.push("-e")
        params.push(env)

      for bind in @binds()
        params.push("-v")
        params.push(bind)

      for client_port, host_ports of @portBindings()
        for host_port in host_ports
          params.push("-p")
          params.push(
            "#{host_port.HostPort}:#{client_port.split("/")[0]}"
          )

      params.push(@image())
      params.concat(@commands())

    # Generates parameters for a Docker CLI call.
    #
    # @return [Object]
    #
    commands: ->
      switch @name
        when "etcd"
          [ "-peer-addr", "127.0.0.1:7001"
            "-addr", "127.0.0.1:4001"
            "-name", "#{os.hostname()}"
            "-discovery=#{@options.discovery_url}"
          ]
        when "nothing"
          [ "/bin/sh"
            "-c"
            "while true; do sleep 1; done"
          ]
        else "bin/#{@name}"

    # Builds the container name from `Docker.image`.
    #
    # @return [String]
    #
    containerName: ->
      "#{Docker.image()}-#{@name}"

    # Generate environment variables to be passed to the container.
    #
    # @return [Array<String>] an array of strings in "VAR=var" format
    #
    envs: ->
      envs = []
      envs.push(
        "DOCKER_HOST=#{@env.DOCKER_HOST}"
      ) if @env.DOCKER_HOST && @env.ENV != "production"
      envs.push(
        "DOCKER_CERT_PATH=/certs/docker"
      ) if @env.DOCKER_CERT_PATH && @env.ENV != "production"
      envs.push(
        "DOCKER_SOCKET_PATH=/var/run/host"
      ) if @env.DOCKER_SOCKET_PATH || @env.ENV == "production"
      envs.push(
        "ENV=#{@env.ENV}"
      ) if @env.ENV
      envs.push(
        "AWS_ACCESS_KEY_ID=#{@env.AWS_ACCESS_KEY_ID}"
      ) if @env.AWS_ACCESS_KEY_ID
      envs.push(
        "AWS_SECRET_ACCESS_KEY=#{@env.AWS_SECRET_ACCESS_KEY}"
      ) if @env.AWS_SECRET_ACCESS_KEY
      envs

    # Generate an object for the `ExposedPorts` option of the Docker
    # API.
    #
    # @return [Object]
    #
    exposedPorts: ->
      ports = @portBindings(@name)
      ports[key] = {} for key, value of ports
      ports

    # Generate a Docker image path.
    #
    # @return [String] a Docker image path
    #
    image: ->
      switch @name
        when "etcd"
          "quay.io/coreos/etcd:v0.4.6"
        else
          Docker.repo()

    # Generate an object for the `PortBindings` option of the
    # Docker API.
    #
    # @return [Object]
    #
    portBindings: ->
      switch @name
        when "etcd"
          "4001/tcp": [ HostPort: "4001" ]
          "7001/tcp": [ HostPort: "7001" ]
        when "www"
          "443/tcp": [ HostPort: "443" ]
          "80/tcp":  [ HostPort: "80" ]
