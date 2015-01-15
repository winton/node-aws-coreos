Aws = require "./aws"

module.exports = (gulp, $) ->
    
  gulp.task "deploy", ->
    console.log "\nOne moment...\n"

    stack = new Aws.Stack()
    stack.create().then console.log