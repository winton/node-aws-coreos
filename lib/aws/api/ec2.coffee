AWS     = require "aws-sdk"
Promise = require "bluebird"

module.exports = (Aws) ->

  # Wrapper for `AWS.EC2`.
  #
  class Aws.Api.Ec2

    # Promisifies `AWS.EC2`.
    #
    constructor: ->
      @ec2 = Promise.promisifyAll(new AWS.EC2())

    # Lists all EC2 instances.
    #
    # @param [Object] params parameters to `AWS.EC2#describeInstances`
    # @return [Promise<Object>]
    # @see http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/EC2.html#describeInstances-property
    #
    listInstances: (params) ->
      @ec2.describeInstancesAsync(params)