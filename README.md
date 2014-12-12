# Puppet-dns

A simple module to run a DNS server inside your virtual machine to resolve fake development domains such as `.vm` and `.local` instead of adding them to your `/etc/hosts`. This is specially needed if your application makes use of dynamic subdomains or you don't want to configure every host.

## Usage
Import the module in your project by cloning this repo into your modules folder, use a submodule or any other approach you desire. An example:

    # From the root directory and seeing the "modules" dir there:
    git submodule add https://github.com/alombarte/puppet-dns.git modules/dns_server
    # Using submodules is not usually a good idea :)

Then just include the class as a dependency inside your `manifests/init.pp` or equivalent and set the parameters:

    include ::dns_server

Or call the class with custom parameters instead. These are the default ones, change what you need:

    class { '::dns_server':
      in_ns      => 'dns-server.local',
      in_a       => $::ipaddress_eth1,
      forwarders => '8.8.8.8',
    }

*Note*: The DNS server 8.8.8.8 is powered by google.

## Client configuration
Once the DNS server is running in the Virtualhost your host machine (the physical machine) needs to use the new DNS server to properly resolve these domains.

This is usually found under `/etc/resolv.conf`. In there:

- Specify in the first entry your virtual machine IP, e.g: `192.168.33.10`
- Leave as a second entry the configuration that you had. **IMPORTANT**: This leaves your internet connection operating when VM is shut down.

### Configuration under Windows :/

- `Control Panel > Network settings` and choose the wired network interface.
- Select `Protocol TCP/PIv4` and click properties (of course you need admin rights)
red off your internet connection still works.
- Manually specify the primary DNS server address and use your virtual machine IP, e.g: `192.168.33.10`
- In the secondary DNS write your old primary DNS server so when the virtual machine is powered off Internet keeps resolving.


## Dependencies
This module relies on two puppet modules that will be download automatically from the forge:

 - [https://github.com/thias/puppet-bind]
 - [https://github.com/puppetlabs/puppetlabs-firewall]

## Troubleshotting
If the DNS resolution does not work basically two things can happen:

- The DNS Server is not running properly
- The client is not using the DNS server

Some things you can try

- Open the terminal INSIDE the virtual machine. Ping any host like `whatever.local`. If it resolves the problem is in the client
- If it doesn't, try to start the daemon `/etc/init.d/named start` (CentOS)
- The client might also be caching the DNS server and not using the virtualmachine one, specially after  power on/off, suspend, hibernate, etc... You can refresh the configuration with `dscacheutil -fluscache` (MacOS)
