# class: nordvpn
#
# @param token The NordVPN token for authentication.
class nordvpn (
  String $token,
) {
  apt::source { 'nordvpn':
    location => 'https://repo.nordvpn.com/deb/nordvpn/debian',
    release  => 'stable',
    repos    => 'main',
    key      => {
      'id'     => 'BC5480EFEC5C081CE5BCFBE26B219E535C964CA1',
      'source' => 'https://repo.nordvpn.com/gpg/nordvpn_public.asc',
    },
    before   => Package['nordvpn'],
  }

  package { 'nordvpn':
    ensure => installed,
  }

  service { 'nordvpnd':
    ensure  => running,
    enable  => true,
    require => Package['nordvpn'],
  }

  exec { 'nordvpn-login':
    command => "/usr/bin/nordvpn login --token ${token}",
    unless  => '/usr/bin/nordvpn account',
    require => Service['nordvpnd'],
  }

  exec { 'nordvpn-connect':
    command => '/usr/bin/nordvpn connect',
    unless  => '/usr/bin/nordvpn status | grep "Connected"',
    require => Exec['nordvpn-login'],
  }
}
