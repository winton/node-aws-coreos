# Generates a release name.
#
# @example
#   new NameGen(["beautiful"], ["mind"]).twerk()
#
class NameGen

  # Assign adjective and nouns.
  #
  # @param [Array<String>] @adjs an array of adjectives
  # @param [Array<String>] @nouns an array of adjectives 
  #
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