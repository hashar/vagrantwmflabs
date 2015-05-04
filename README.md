Boot a Wikimedia Labs instance in Vagrant -in theory-
=====================================================

A lame attempt to bootstrap an Ubuntu Trusty image suitable for Wikimedia labs infrastructure and provisionned by existing manifests in operations/puppet.git.

Ideally I would want to include the puppet class ::base, ::role::labs::instance and ::role::ci::slave::labs.

Install
-------

    git clone ssh://gerrit.wikimedia.org:29418/operations/puppet.git puppet
	git clone ssh://gerrit.wikimedia.org:29418/labs/private.git
	vagrant box add trusty-cloudimg-amd64 https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box
	vagrant up --provider=virtualbox

Optionally:

	vagrant plugin add vagrant-cachier

Known issues
------------

Wikimedia GPG keyring is not in puppet, have to wget it :(

The puppet runs override resolv.conf / sudo / pam etc which render the box inaccessible. `contintcloud.pp` uses dirty puppet trick to override some resources.

Wikimedia apt configuration should be realized first. Somehow `base::standard-packages` is realized before `require ::apt`and thus some packages are not found (`arcconf ` and `megacli`) but others are (`quickstack`).

`/usr/local/sbin/grain-ensure add instanceproject contintcloud` fails with no message.

Puppet `Ldap::Client::Pam/File[/etc/pam.d/sshd]` is realized preventing us from sshing in the vagrant box, despite a hack in contintcloud.
