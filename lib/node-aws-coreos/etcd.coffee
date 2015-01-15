Promise  = require("bluebird")
NodeEtcd = require("node-etcd")

# A very simple wrapper that Promisifies `node-etcd`.
#
module.exports = class Etcd

  # Get a promisified `NodeEtcd` client.
  #
  # @note uses a hardcoded IP address for the CoreOS etcd server
  # @return [NodeEtcd]
  #
  @client: ->
    Promise.promisifyAll(new NodeEtcd(
      "172.17.42.1" if process.env.ENV == "production"
    ))