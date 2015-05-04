class harnessbase inherits base::resolving {
  File['/etc/resolv.conf'] {
    content  => undef,
  }
}

class harnesspamsshd inherits ldap::client::pam {
  File['/etc/pam.d/sshd'] {
    content => undef,
  }
}

class harnesssshserver inherits ssh::server {
  File['/etc/ssh/sshd_config'] {
    content => undef,
  }
}

class nolabsmount inherits role::labs::instance {

  Mount['/data/project'] {
    ensure => present
  }
  Mount['/data/scratch'] {
    ensure => present
  }
  Mount['/home'] {
    ensure => present
  }
  Mount['/public/dumps'] {
    ensure => present
  }
  Mount['/public/keys'] {
    ensure => present
  }
}

class imagier {

  require ::apt

# operations/puppet overrides Vagrant ssh config
  ssh::userkey { 'vagrant':
      source => 'file:///home/vagrant/.ssh/authorized_keys',
  }

  import 'puppet/manifests/site.pp'

  exec { 'install_sudo_ldap':
    command     => '/usr/bin/apt-get install --assume-yes --force-yes sudo-ldap',
    environment => 'SUDO_FORCE_REMOVE=yes',
    before      => Class['Sudo'],
  }

  include harnessbase
  include ::base

  include nolabsmount
  include harnesspamsshd
  include harnesssshserver
  #include role::labs::instance
  #include role::ci::slave::labs
}


include imagier
