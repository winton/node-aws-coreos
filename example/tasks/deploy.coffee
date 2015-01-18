Aws     = require "node-aws-coreos/lib/aws"
NameGen = require "node-aws-coreos/lib/name_gen"
path    = require "path"

NameGen.adjectives = [
  "beautiful", "smart", "transcendent", "inspiring", "loving"
]

NameGen.nouns = [
  "pug", "chweenie"
]

module.exports = (gulp, $) ->

  gulp.task "deploy", ->
    console.log "\nOne moment...\n"
    cfn_path = path.resolve("lib/cfn.coffee")
    new Aws.Stack(cfn_path).create().then console.log