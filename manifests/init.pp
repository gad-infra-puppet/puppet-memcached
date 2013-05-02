class memcached(
  $package_ensure  = 'present',
  $logfile         = '/var/log/memcached.log',
  $max_memory      = false,
  $item_size       = false,
  $lock_memory     = false,
  $listen_ip       = '0.0.0.0',
  $tcp_port        = 11211,
  $udp_port        = 11211,
  $user            = $::memcached::params::user,
  $max_connections = '8192',
  $verbosity       = undef,
  $unix_socket     = undef,
  $install_dev     = false
) inherits memcached::params {

  package { $memcached::params::package_name:
    ensure => $package_ensure,
  }

  if $install_dev {
    package { $memcached::params::dev_package_name:
      ensure  => $package_ensure,
      require => Package[$memcached::params::package_name]
    }
  }

  if $tcp_port == 11211 {
    $suffix = ""
    $real_name = "memcached"
  } else {
    $udp_port = $tcp_port

    $suffix = "_${tcp_port}"
    $real_name = "memcached_${tcp_port}"
  }

  case $::osfamily {
    'Debian': {
      file { 
      "${memcached::params::init_file}${suffix}":
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template($memcached::params::init_tmpl),
        require => Package[$memcached::params::package_name];
      "${memcached::params::default_file}${suffix}":
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        source  => $memcached::params::default_src,
        require => Package[$memcached::params::package_name];
      "${memcached::params::config_file}${suffix}":
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template($memcached::params::config_tmpl),
          require => Package[$memcached::params::package_name],
      }

      service { "${memcached::params::service_name}${suffix}":
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => false,
        subscribe  => File["${memcached::params::config_file}${suffix}"],
      }

    }
    'RedHat': {
      fail("Multiple memcached configuration is not yet supproted and tested.: ${::osfamily}")
    }
    default: {
      fail("Unsupported platform: ${::osfamily}")
    }
  }

}