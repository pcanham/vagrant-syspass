Yumrepo <| |> -> Package <| |>

node default {

  # Death to the allow_virtual_packages warning
  if versioncmp($::puppetversion,'3.6.1') >= 0 {
    $allow_virtual_packages = hiera('allow_virtual_packages',false)
    Package {
      allow_virtual => $allow_virtual_packages,
    }
  }

  class { 'firewall': }

  firewall { "006 Allow inbound http(s) (v4)":
    port     => [80, 443],
    proto    => tcp,
    action   => accept
  }

  class { 'epel': }

  class { 'timezone':
        timezone => 'UTC',
  }
  class { 'apache':
    default_vhost => false,
  }

  class { 'apache::mod::php':  }

  $user = 'apache'
  $syspasspath = '/var/www/syspass'

  apache::vhost { 'syspass.sandbox.internal':
    port        => '80',
    docroot     => $syspasspath,
    serveradmin => 'admin@localhost'
  }

  @package {"php-mysql":
    ensure => installed,
  }

  @package {"php-pdo":
    ensure => installed,
  }

  @package {"php-ldap":
    ensure => installed,
  }

  @package {"php-gd":
    ensure => installed,
  }

  @package {"php-mcrypt ":
    ensure => installed,
  }

  @package {"wget":
    ensure => installed,
  }

  @package {"mariadb ":
    ensure => installed,
  }

  realize Package[ "php-mysql", "php-pdo", "php-ldap", "php-gd", "php-mcrypt", "wget", "mariadb" ]

  staging::deploy { '1.2.0.11.tar.gz':
    source => 'https://github.com/nuxsmin/sysPass/archive/1.2.0.11.tar.gz',
    target => '/var/www'
  }

  file { 'sysPass-htdocs':
    name     => '/var/www/sysPass',
    ensure   => 'directory',
    recurse  => true,
    owner    => 'apache',
    group    => 'apache',
    require  => [ Package['httpd'],
                  Staging::Deploy['1.2.0.11.tar.gz']
                ]
  }

  file { 'sysPass-htdocs-config':
    name     => '/var/www/sysPass/config',
    ensure   => 'directory',
    mode     => '0750',
    owner    => 'apache',
    group    => 'apache',
    require  => File['sysPass-htdocs'],
  }
}
