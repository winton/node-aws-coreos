module.exports = (Aws) -> 

  # Create and list CloudFormation stacks.
  #
  class Aws.Stack

    # Initialize `Aws.Api.Cfn`.
    #
    # @param [String] @template_path path to the CloudFormation template
    #
    constructor: (@template_path) ->
      @cfn = new Aws.Api.Cfn()

    # Create a CloudFormation stack.
    #
    # @return [Promise<Object>]
    #
    create: ->
      @params = new Aws.Stack.Params(@template_path)
      @params.build().then (params) =>
        #@cfn.createStack(params)
        params

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