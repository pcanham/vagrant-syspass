node default {

  # Death to the allow_virtual_packages warning
  if versioncmp($::puppetversion,'3.6.1') >= 0 {
    $allow_virtual_packages = hiera('allow_virtual_packages',false)
    Package {
      allow_virtual => $allow_virtual_packages,
    }
  }

  class { 'timezone':
        timezone => 'UTC',
  }

  class { 'firewall': }

  firewall { "006 Allow inbound MySQL (v4)":
    port     => 3306,
    proto    => tcp,
    action   => accept
  }

  class { 'mysql::server':
    root_password    => 'strongpassword',
    override_options => { 'mysqld' => { 'max_connections' => '128',
                                        'bind-address'    => '0.0.0.0',
                                        'default-storage-engine' => 'InnoDB'
                                      }
                        }
  }
  class { 'mysql::server::account_security': }

  class { 'mysql::server::mysqltuner': }

  mysql::db { 'syspassdb':
    user        => 'syspassuser',
    password    => 'syspasspass',
    host        => '%',
    grant       => [ 'SELECT', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'DROP', 'ALTER', 'CREATE TEMPORARY TABLES', 'LOCK TABLES' ],
  }
}
