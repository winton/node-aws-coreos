Docker  = require("./docker")
Etcd    = require("./etcd")
Promise = require("bluebird")
os      = require("os")

# A simple CoreOS sidekick that reports docker information to etcd.
#
module.exports = class Sidekick

  # Create two etcd clients, one for setting and one for listening.
  #
  # Also creates a `Docker.Container` instance.
  #
  constructor: ->
    @etcd_set   = Etcd.client()
    @etcd_watch = Etcd.client()
    @container  = new Docker.Container()

  # Etcd key used to store Docker container info.
  #
  # @param [String] container name
  # @return [String] an etcd key containing the host and container name
  #
  containerKey: (container) ->
    [ ""
      "instances"
      os.hostname()
      "container"
      container
      "image"
    ].join("/")

  # Store Docker container info to etcd.
  # 
  setEtcd: ->
    @container.ps().map (container) =>
      @etcd_set.setAsync(
        @containerKey(
          container.Names[0].substring(1)
        )
        container.Image.split(/:/)[0]
        ttl: 20
      )

  # Starts a timer that stores Docker container info every 10 seconds.
  #
  start: ->
    setTimeout(
      => @setEtcd()
      10*1000
    )
    @setEtcd()

  # Watches etcd for changes.
  #
  # @param [Function] fn the function to call when etcd changes
  # @return [EventEmitter]
  #
  watchEtcd: (fn) ->
    watcher = @etcd_watch.watcher(
      "instances"
      null
      recursive: true
    )

    watcher.on("change", fn)
    watcher.on("error",  console.error)
    
    watcher