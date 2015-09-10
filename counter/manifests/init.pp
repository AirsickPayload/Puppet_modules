include wget
# WORK IN PROGRESS!
# Uptime Counter Puppet module
# Database preview available through http://localhost:9696
# Written by Alan Matuszczak
# LICENSED UNDER GPL v2 LICENSE, SEE http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
class counter (
  String $counter_download_url = 'https://seacloud.cc/f/44b044bd6e/?dl=1',
){
# WARNING UBUNTU AND DEBIAN USERS: THIS MODULE ASSUMES THAT YOUR ARE USING
# A RECENT VERSION OF YOUR DISTRO, ONE WHICH INCLUDES SYSTEMD BY DEFAULT
# UBUNTU 15.04+ AND DEBIAN 8+ !
  $service_file_url = $::operatingsystem ? {
    'Fedora', 'Ubuntu', 'Debian' => 'https://seacloud.cc/f/896b41797b/?dl=1',
  }

  $sqlite_package =  $::osfamily ? {
    'RedHat'  => 'rubygem-sqlite3',
    'Debian' => 'ruby-sqlite3',
    default => 'ruby-sqlite3',
  }

  $wget_package = $::operatingsystem ? {
    default => 'wget',
  }

  $provider_name = $::osfamily ? {
      'RedHat'  => 'yum',
      'Debian' => 'apt',
  }

  $service_enable = $::osfamily ? {
    default => 'systemctl enable counter.service',
  }

  $service_start = $::osfamily ? {
    default => 'systemctl start counter.service',
  }

  $service_path = $::osfamily ? {
    default => '/etc/systemd/system/counter.service',
  }

package {'wget package':
  name    => $wget_package,
  provide => $provider_name,
}

package { 'sqlite3 ruby gem':
  name     => $sqlite_package,
  provider => $provider_name,
}

exec { 'Download counter file':
  path    => ['/usr/bin', '/usr/sbin'],
  creates => '/tmp/counter.rb',
  command => "wget ${counter_download_url} -O /tmp/counter.rb",
}

exec { 'Download service file':
  path    => ['/usr/bin', '/usr/sbin'],
  creates => '/tmp/counter.file',
  command => "wget ${service_file_url} -O /tmp/counter.file",
}

file { 'Counter directory':
  ensure => 'directory',
  path   => '/opt/counter',
}

file { 'Copy the ruby executable to the right directory':
  ensure => file,
  path   => '/opt/counter/counter.rb',
  source => '/tmp/counter.rb',
  mode   => '0744',
}

file { 'Copy service file to appropriate directory':
  ensure => file,
  path   => $service_path,
  source => '/tmp/counter.file',
  mode   => '0744',
}

exec { 'Remove duplicate files from /tmp':
  path    => ['/usr/bin', '/usr/sbin'],
  command => 'rm /tmp/counter.service /tmp/counter.rb'
}

exec { 'Enable the counter service':
  path    => ['/usr/bin', '/usr/sbin'],
  command => $service_enable,
}

exec{ 'Start the counter service':
  path    => ['/usr/bin', '/usr/sbin'],
  command => $service_start,
}
}
