# Introduction

Describe your infrastcuture in YML like this:

    ---
    droplets:
      - name: development.web.1
      - name: development.app.1
      - name: development.db.1
      - name: production.web.1
        region: 2
      - name: production.web.2
      - name: production.app.1
        region: 2
      - name: production.app.2
      - name: production.db.1
        size: 65

Run an ansible playbook to create droplets on Digital Ocean, and then run
ansible to execute remote commands across groups of newly created machines.

# Purpose

This repository is mainly an exploration of Ansibles provisioning and
orchestration capabilities. It's tied to using the Digital Ocean cloud
provider just to make testing easier, but in principle could be extended
or altered to support other providers.

It allows you to define a set of droplets in a file, then use Ansible to
create those instances. Once created Ansible uses the Digital Ocean API
to discover the addresses and for you to run commands across portions of
your new infrastructure. Because Digital Ocean doesn't yet support any
sort of metadata on droplets the name is used to encode information. 


# Installation

After cloning this repository you need to install Ansible and a couple of
dependencies.

    pip install -r requirements.txt

Note that this currently uses a pre-release version of Ansible which
provides an improved version of the Digital Ocean module.

You also need to set a couple of environment variables for the Digital
Ocean API.

    export DO_API_KEY=xxxxxxxxxxxxxxx
    export DO_CLIENT_ID=xxxxxxxxxxxxxxxxxx


# Usage

The repository contains example files for you to try out but the format
is quiet simple. First up lets use a simple example that creates a
single droplet (remember this requires you to have a Digital Ocean
account and will cost you money):

    cp vars/small.yml.example vars/droplets.yml
    cp vars/custom.yml.example vars/custom.yml
    cp host_vars/localhost.example host_vars/localhost

You'll now need to edit `vars/custom.yml` and enter the numberic id of
your ssh key. This is needlessly fiddly, I would recommend first
installing the [Tugboat](https://github.com/pearkes/tugboat) client and
then running:

    tugboat keys

With that done we can idempotently create the machines specified in the
above file simply by running the playbook. Note that the first run will take
a few seconds while it hits the Digital Ocean API but these results are cached.

    ansible-playbook -i hosts provision_digital_ocean.yml

Now you have some machines up and running you can use the ansible tool
to list the hosts, or to run arbitrary commands on them like so.

    ansible -i hosts all --list-hosts
    ansible -i hosts all -a 'uptime'

# Groups

More useful is if you adopt a strong naming convention for your
droplets. Note the following template:

    <environment>.<type>.<id>

Using this format will generate Ansible groups for all environments used
and for all combinations of environment/type. For instance the above
example configuration will create groups for:

* production
* development
* development_web
* development_app
* development_db
* production_web
* production_app
* production_db

This means you can direct commands easily to the relevant droplets like
so:
    
    ansible -i hosts production_web -a 'uptime'

# Advanced

Default values for the region, size and base image are provided in the
`host_vars/localhost.example` file. This should be copied to 
`host_vars/localhost` from where it can be edited. You can override the
provided values with your own values as well as specify these on a per droplet 
basis if required.

The following places two droplets in Amsterdam and increases the size of the 
production.db.1 droplet to 8GB. 

    ---
    droplets:
      - name: development.web.1
      - name: development.app.1
      - name: development.db.1
      - name: production.web.1
        region: 2
      - name: production.web.2
      - name: production.app.1
        region: 2
      - name: production.app.2
      - name: production.db.1
        size: 65

To get at the numeric ids you need for this again I'd recommend the
Tugboat client mentioned above.
