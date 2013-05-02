class memcached::config (
  $max_memory      = false,
  $item_size       = false,
  $lock_memory     = false,
  $listen_ip       = '0.0.0.0',
  $tcp_port        = false,
  $max_connections = '8192',
  $verbosity       = undef,
  $unix_socket     = undef,
) inherits memcached::params {

  if $tcp_port {
    $udp_port = $tcp_port
    $real_name = "memcached_${tcp_port}"
  } else {
    fail("tcp_port is required: memcached::config")
  }

  case $::osfamily {
    'Debian': {
      file { 
      "${memcached::params::init_file}_${tcp_port}":
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template($memcached::params::init_tmpl),
        require => Package[$memcached::params::package_name];
      "${memcached::params::default_file}_${tcp_port}":
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        source  => $memcached::params::default_src,
        require => Package[$memcached::params::package_name];
      "${memcached::params::config_file}_${tcp_port}":
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template($memcached::params::config_tmpl),
          require => Package[$memcached::params::package_name],
      }

      service { "${memcached::params::service_name}_${tcp_port}":
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => false,
        subscribe  => File["${memcached::params::config_file}_${tcp_port}"],
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