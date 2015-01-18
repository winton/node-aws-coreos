path    = require "path"
Promise = require "bluebird"
request = require "request-promise"
fs      = Promise.promisifyAll(require "fs")

module.exports = (Aws) ->

  # Generates parameters for `AWS.CloudFormation#createStack`.
  #
  # @see http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/CloudFormation.html#createStack-property
  #
  class Aws.Stack.Params

    # Initializes `AWS.Stack.Input`.
    #
    # @param [String] @template_path path to your CloudFormation template
    #
    constructor: (@template_path) ->
      @input = new Aws.Stack.Input()

    # Build `createStack` parameters.
    #
    # @return [Promise<Object>]
    #
    build: ->
      Promise.props(
        discovery_url: @etcdDiscoveryUrl()
        stack_name:    @input.getStackName()
        template:      @cfnTemplate()
      )
      .then (options) =>
        StackName: options.stack_name
        Parameters: [
          ParameterKey: "DiscoveryURL"
          ParameterValue: options.discovery_url
        ]
        TemplateBody: options.template.toString()

    # Reads the CloudFormation template and converts it to JSON.
    #
    # @return [String]
    #
    cfnTemplate: ->
      JSON.stringify(
        require @cfnTemplatePath()
        null
        2
      )

    # Resolves the CloudFormation template path.
    #
    # @return [String]
    #
    cfnTemplatePath: ->
      path.resolve(__dirname, @template_path)

    # Grab a new etcd discovery URL through the `etcd.io` API.
    #
    # @return [Promise<Object>]
    # @todo move to Etcd
    #
    etcdDiscoveryUrl: ->
      request("https://discovery.etcd.io/new")