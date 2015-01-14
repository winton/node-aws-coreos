module.exports = (Aws) -> 

  # Create and list CloudFormation stacks.
  #
  class Aws.Stack

    # Initialize `Aws.Api.Cfn`.
    #
    constructor: ->
      @cfn = new Aws.Api.Cfn()

    # Create a CloudFormation stack.
    #
    # @return [Promise<Object>]
    #
    create: ->
      @params = new Aws.Stack.Params()
      @params.build().then (params) =>
        @cfn.createStack(params)

    # List all CloudFormation stacks.
    #
    # @param [Object] params parameters to `AWS.CloudFormation#listStacks`
    # @return [Promise<Object>]
    #
    list: (params) ->
      @cfn.listStacks(params)

    # List running CloudFormation stacks.
    #
    # @param [Object] params parameters to `AWS.CloudFormation#listStacks`
    # @return [Promise<Object>]
    #
    listRunning: (params) ->
      @cfn.listRunningStacks(params)

  require("./stack/input")(Aws)
  require("./stack/params")(Aws)