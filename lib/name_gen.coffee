# Generates a release name.
#
# @example
#   new NameGen().twerk()
#
class NameGen

  constructor: (@adjs, @nouns) ->

  # Randomly combine an adjective and a noun, joined by a dash (-).
  #
  # @return [String]
  #
  twerk: ->
    [ @adjectives[Math.floor(Math.random()*@adjectives.length)]
      @nouns[Math.floor(Math.random()*@nouns.length)]
    ].join("-")

module.exports = NameGen