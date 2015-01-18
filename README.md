# NodeAwsCoreOS

Helper classes to run a CoreOS stack on AWS and your local machine.

## Set up

The [example directory](https://github.com/winton/node-aws-coreos/tree/master/example) contains a basic project set up.

* `bin` - Contains executable files that run within the docker container
* `lib/cfn.coffee` - The CloudFormation file that uses [`Docker.Args`](https://github.com/winton/node-aws-coreos/blob/master/lib/docker/args.coffee) to generate arguments for Docker calls in systemd services
* `tasks/deploy.coffee` - Gulp task to deploy a CloudFormation stack
* `Gulpfile` - Uses [`Straw`](https://github.com/winton/node-aws-coreos/blob/master/lib/straw.coffee) to load tasks

## Dev setup

	npm install

## Build docs

	node_modules/.bin/codo lib
	open docs/index.html