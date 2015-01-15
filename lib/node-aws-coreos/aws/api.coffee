module.exports = (Aws) -> 

  # Namespace for Aws.Api classes.
  #
  class Aws.Api

  require("./api/cfn")(Aws)
  require("./api/ec2")(Aws)