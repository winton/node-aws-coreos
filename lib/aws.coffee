AWS = require "aws-sdk"
fs  = require "fs"

# Namespace for Aws classes. Also stores `.aws` configuration
# and updates the `AWS.config` region.
#
class Aws

  # Parsed `.aws` configuration JSON.
  #
  @config: JSON.parse(
    fs.readFileSync("#{process.cwd()}/.aws", "utf8")
  )

  # Updates the `AWS.config` region.
  #
  # @note this method executes when the library is required
  #
  @updateRegion: ->
    AWS.config.update(
      region: process.env.AWS_REGION || @config.region
    )

Aws.updateRegion()

require("./aws/api")(Aws)
require("./aws/stack")(Aws)

module.exports = Aws