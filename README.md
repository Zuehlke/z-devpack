# Windows DevPack (Generator)

A set of scripts for creating Windows Devpacks.

An example DevPack for Ruby/git/terraform/aws

## What is a DevPack?

A DevPack is a development environment in a .zip file.

It is meant to be used without installation procedures and it's startup scripts establish an environment isolated from the host Windows installation.

Download the package, unpack and run ```devpack.cmd``` with a console configured in the devpack environment.

## When to use?

Zühlke projects rely heavily on automated procedures. Call it DevOps, call it CI, call it whatever you want, we aim to encode our teams' expertise in scripts to ease the process of handing projects over to our clients.

To that purpose we rely heavily on open source tools and the command line.
A devpack is our solution to deploying toolchains with minimal interference to and from Windows installations.

Devpacks are designed to co-exist in the same Windows host, working in parallel but not interfering with each other or the host so they are best suited for development and administrative roles. To put it differently: when deploying production systems choose an established provisioning solution like Chef, Puppet or Ansible and when you are providing tools for developers and operators/administrators use a devpack.