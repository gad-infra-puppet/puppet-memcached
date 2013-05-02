class memcached::params {
  case $::osfamily {
    'Debian': {
      $package_name     = 'memcached'
      $service_name     = 'memcached'
      $dev_package_name = 'libmemcached-dev'
      $config_file      = '/etc/memcached.conf'
      $config_tmpl      = "$module_name/memcached.conf.erb"
      $init_file        = "/etc/init.d/memcached"
      $init_tmpl        = "$module_name/memcached_init_debian.erb"
      $default_file     = "/etc/default/memcached"
      $default_src      = "$module_name/memcached_default"
      $start_daemon_tmpl= "$module_name/start-memcached.erb"
      $user             = 'nobody'
    }
    'RedHat': {
      $package_name     = 'memcached'
      $service_name     = 'memcached'
      $dev_package_name = 'libmemcached-devel'
      $config_file      = '/etc/sysconfig/memcached'
      $config_tmpl      = "$module_name/memcached_sysconfig.erb"
      $init_file        = "/etc/init.d/memcached"
      $init_tmpl        = "$module_name/memcached_init.erb"
      $user             = 'memcached'
    }
    default: {
      fail("Unsupported platform: ${::osfamily}")
    }
  }
}
