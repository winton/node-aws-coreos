ask     = require "../../ask"
Docker  = require "../../docker"
NameGen = require "../../name_gen"
Promise = require "bluebird"

module.exports = (Aws) ->

  # Gather stack name input for `Aws.Stack.Params`.
  #
  class Aws.Stack.Input

    # Retrieves image name and `Aws.Stack` object.
    #
    constructor: ->
      @name  = Docker.image()
      @stack = new Aws.Stack()

    # Ask for the user to accept stack name or type a new one.
    #
    # @return [Promise<String>]
    #
    ask: (name) ->
      ask(
        @questionText(name)
        ///(^\s*$|#{@name}-.+)///
      )

    # Generate an unused stack name.
    #
    # @return [Promise<String>]
    #
    generateName: ->
      @stack.listRunning().then (stacks) =>
        name = null

        loop
          name = new NameGen().twerk()
          name = [ @name, name ].join("-")
          
          break unless stacks.filter(
            (stack) -> stack.StackName == name
          ).length

        name

    # Generates a stack name and then asks if that name works.
    #
    # @return [Promise<String>]
    #
    getStackName: ->
      @generateName().then((name) ->
        Promise.props(
          name: name
          new_name: @ask(name)
        )
      ).then (options) =>
        if ///#{@name}-.+///.test(options.new_name)
          options.new_name
        else
          options.name

    # Question text.
    #
    # @param [String] name generated stack name
    # @return [String]
    #
    questionText: (name) ->
      """
      Press enter to accept name "#{name}" or type your own:
      """