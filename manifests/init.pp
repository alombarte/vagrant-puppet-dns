# Bind (DNS) Server to allow resolving all *.vm and *.local addresses to VM.
# Note: You should point to the VM as main DNS server on the host machine.
class dns_server(
	$in_ns      = 'dns-server.local',
	$in_a       = $::ipaddress_eth1,
	$forwarders = '8.8.8.8',
) {
	class { '::bind::server': chroot => false }

	::bind::server::conf { '/etc/named.conf':
		listen_on_addr => [ 'any' ],
		allow_query => [ 'any' ],
		# Your offices DNS server or any other external DNS
		forwarders => [ $forwarders ],
		zones => {
			'vm.' => [
				'type master',
				'file "local.vm"',
			],
			'local.' => [
				'type master',
				'file "local.vm"',
			]
		},
	}

	::bind::server::file { 'local.vm':
		content => template("${module_name}/bind.erb"),
	}

    # Allow connections to the dns server in the firewall:

	firewall { '0101-INPUT ACCEPT DNS-UDP':
		proto   => 'udp',
		port    => 53,
		action  => 'accept',
	}

	firewall { '0102-INPUT ACCEPT DNS-TCP':
		proto   => 'tcp',
		port    => 53,
		action  => 'accept',
	}
}
