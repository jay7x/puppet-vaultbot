# vaultbot

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with vaultbot](#setup)
    * [What vaultbot affects](#what-vaultbot-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with vaultbot](#beginning-with-vaultbot)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Puppet module to install and configure [vaultbot](https://gitlab.com/msvechla/vaultbot/).

## Setup

### What vaultbot affects

* vaultbot binary
* vaultbot configuration files
* vaultbot timer and service

### Setup Requirements

Please review [metadata.json](metadata.json) for a list of requirements.

### Beginning with vaultbot

Use the `vaultbot::bundle` defined resource to configure certificate bundles you'd like to manage.

## Usage

TBD

## Reference

Reference documentation for the module is generated using
[puppet-strings](https://puppet.com/docs/puppet/latest/puppet_strings.html) and
available in [REFERENCE.md](REFERENCE.md)

## Limitations

The module has been built on and tested against Puppet 6 and higher.

The module has been tested on:

* Debian 11
* Ubuntu 20.04

## Development

Please contribute to the module on GitHub: <https://github.com/jay7x/puppet-vaultbot>.

## Copyright and License

This module is distributed under the [Apache License 2.0](LICENSE).  Copyright belongs to the module's authors, including Yury Bushmelev and
[others](https://github.com/jay7x/puppet-vaultbot/graphs/contributors).
