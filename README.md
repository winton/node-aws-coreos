# NodeAwsCoreOS

Helper classes to run a CoreOS stack on AWS and your local machine.

## Set up

The [example directory](https://github.com/winton/node-aws-coreos/tree/master/example) contains a basic project set up that runs a ["sidekick"](https://coreos.com/docs/launching-containers/launching/launching-containers-fleet) and an nginx server.

* [`bin`](https://github.com/winton/node-aws-coreos/tree/master/example/bin) - Contains executable files that run within the Docker container to start services
* [`lib/cfn.coffee`](https://github.com/winton/node-aws-coreos/blob/master/example/lib/cfn.coffee) - The CloudFormation file that uses [`Docker.Args`](https://github.com/winton/node-aws-coreos/blob/master/lib/docker/args.coffee) to generate arguments for Docker calls in systemd services
* [`tasks/deploy.coffee`](https://github.com/winton/node-aws-coreos/blob/master/example/tasks/deploy.coffee) - Gulp task to deploy a CloudFormation stack
* [`.docker`](https://github.com/winton/node-aws-coreos/blob/master/example/.docker) - Defines the path to the remote Docker container repository
* [`Gulpfile`](https://github.com/winton/node-aws-coreos/blob/master/example/Gulpfile) - Uses [`Straw`](https://github.com/winton/node-aws-coreos/blob/master/lib/straw.coffee) to load tasks
* [`package.json`](https://github.com/winton/node-aws-coreos/blob/master/example/package.json) - Adds `node-aws-coreos` as a Node.js dependency

This structure is meant to be added to any existing project.

## Dev setup

	npm install

## Build docs

	node_modules/.bin/codo lib
	open docs/index.html