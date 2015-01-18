# Generates a release name.
#
# @example
#   NameGen.adjectives = [ "beautiful" ]
#   NameGen.nouns      = [ "mind" ]
#   NameGen.twerk()
#
class NameGen

  # Randomly combine an adjective and a noun, joined by a dash (-).
  #
  # @return [String]
  #
  @twerk: ->
    [
      @adjectives[Math.floor(
        Math.random() * @adjectives.length
      )]
      @nouns[Math.floor(
        Math.random() * @nouns.length
      )]
    ].join("-")

module.exports = NameGen