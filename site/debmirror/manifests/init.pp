class debmirror {
  include debmirror::user
  include debmirror::aptly
}

class debmirror::user { 
	$gid_num = '6666'
	$uid_num = "$gid_num"

	group {'debmirror_group':
		name 		=> 'debmirror',
		ensure 		=> 'present',
		gid 		=> $gid_num,
		alias 		=> 'debmirror_group'
	}

	user { 'debmirror_user':
		name 		=> 'debmirror',
		ensure 		=> 'present',
		gid 		=> $gid_num,
		uid 		=> $uid_num,
		expiry 		=> absent,
		managehome 	=> true,
		require 	=> Group['debmirror_group'],
		alias 		=> 'debmirror_group',
	}
}

class debmirror::aptly {
	file { '/usr/local/bin/aptly':
		source 		=> "puppet:///modules/debmirror/aptly",
		ensure 		=> present,
		mode 		=> '0711',
		owner 		=> 'root',
		group 		=> 'root',
		alias 		=> 'aptly_binary',
	}

	file {'/debmirror':
		path 		=> '/debmirror',
		ensure 		=> directory,
		mode 		=> '755',
		owner		=> 'debmirror',
		group 		=> 'debmirror',
		require		=> User['debmirror_user'],
		alias		=> 'debmirror_root_dir'
	}

	file {'/etc/aptly.conf':
		ensure		=> file,
		content		=> template('debmirror/aptly.conf.erb'),
		mode 		=> '0744',
		owner		=> 'root',
		group 		=> 'root',
		require		=> File['aptly_binary'],
		alias 		=> 'aptly_conf',
	}

	exec {'import_ubuntu_archive_gpg_pubkey':
		command		=> '/usr/bin/gpg --no-default-keyring --keyring trustedkeys.gpg --keyserver pool.sks-keyservers.net --recv-keys 3B4FE6ACC0B21F32',
		returns		=> [0,2],
		unless		=> '/usr/bin/gpg --no-default-keyring --keyring /home/debmirror/.gnupg/trustedkeys.gpg --list-keys C0B21F32',
		user 		=> 'debmirror',
		environment => ['HOME=/home/debmirror'],
		#path 		=> '/usr/local/bin,/usr/bin,/usr/local/sbin,/usr/sbin,/opt/puppetlabs/bin',
		alias 		=> 'import_ubuntu_pubkey',
	}
}