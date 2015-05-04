# vim: set ft=ruby :
#
#
# vagrant box add trusty-cloudimg-amd64 https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box
#
# vagrant up --provider=libvirt

Vagrant.configure('2') do |config|

	config.vm.box      = 'ubuntu/trusty64'
	config.vm.hostname = 'ci-image'

	# Assign the first IP from eqiad.wmflabs network range
	# that tricks puppet in figuring out $site
	config.vm.provider 'virtualbox' do |v|
		  v.customize ['modifyvm', :id, '--natnet1', '10.68.16.0/21']
	end

	# vagrant plugin install vagrant-cachier
	if Vagrant.has_plugin?('vagrant-cachier')
		config.cache.scope = :box
	end

	# ::apt puppet class does not provide our GPG keyring :-/
	config.vm.provision 'shell',
		inline: <<-BASH
		set -e
		apt-get install -y wget
		echo "Injecting Wikimedia APT configuration"
		if [ ! -f /etc/apt/trusted.gpg.d/wikimedia-archive-keyring.gpg ]; then
			wget -O /etc/apt/trusted.gpg.d/wikimedia-archive-keyring.gpg http://apt.wikimedia.org/autoinstall/keyring/wikimedia-archive-keyring.gpg
		fi
	BASH

	config.vm.provision :puppet do |puppet|
		puppet.manifests_path = 'puppet/manifests'
		puppet.hiera_config_path = 'hiera.yaml'

		# Required but overridden below with /vagrant/contintcloud.pp
		puppet.manifest_file = 'site.pp'

		puppet.options = [
			'--templatedir', '/vagrant/puppet/templates',
			'--modulepath', '/vagrant/puppet/modules:/vagrant/private/modules',
			'--fileserverconfig', '/vagrant/fileserver.conf',
			'--verbose',
			'--logdest', '/vagrant/log/puppet/puppet.log',
			'--logdest', 'console',
			'--write-catalog-summary',
			'/vagrant/contintcloud.pp',
		]
		puppet.options << '--debug' if ENV.include?('PUPPET_DEBUG')

		puppet.facter = $FACTER = {
			'ec2id'              => 'fakeec2id',
			'fqdn'               => config.vm.hostname,
			'realm'              => 'labs',
			'instanceproject'    => 'contintcloud',
			'use_dnsmasq'        => true,
			'use_dnsmasq_server' => true,

			'shared_apt_cache'   => '/vagrant/cache/apt/',
			'environment'        => 'vagrant',
		}

	end
end
