# Lorry API

[Lorry](https://lorry.io) is a project from the team at [CenturyLink Labs](http://www.centurylinklabs.com/).  This utility provides a browser-based validator and builder for [Docker Compose YAML files](https://docs.docker.com/compose/yml/).  A docker-compose.yml can be imported or built from scratch.  You can even import Panamax templates and convert them to docker-compose.yml files.  

The initial import and subsequent modifications of a document triggers validation against a YAML schema derived from the latest [Compose documentation](https://docs.docker.com/compose/).  The utility differentiates between errors which prevent the application defined in the docker-compose.yml from being stood up with Compose and warnings which simply point out things in the document that might not be what you want.  

The Lorry project will make creating docker-compose.yml files easier with its user-friendly interface that provides documentation for Compose options and limits choices of keys to those specified in the [docker-compose.yml reference](https://docs.docker.com/compose/yml/). 

Once you're done crafting the docker-compose.yml, Lorry makes it simple to save your document as a file, copy it to the clipboard, and even share it with others as a Gist or with a Lorry URL for collaborative editing.

## NOTE

This repo is no longer being maintained. Users are welcome to fork it, but we make no warranty of its functionality.

## Installation
The Lorry API is a Ruby application that uses Sinatra

```
$ git clone git@github.com:CenturyLinkLabs/lorry.git
$ bundle
$ bundle exec rspec # should all pass
$ rackup
```

## Lorry UI Project
Lorry is the API component of the [Lorry UI project](https://github.com/CenturyLinkLabs/lorry-ui/).

## Lorry In Action
You can see the hosted version of Lorry at [lorry.io](https://lorry.io).
