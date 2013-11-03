$installation_mount = "/mnt/smallworld_install"
$installation_iso_file = "/vagrant/install/CORE420_UNIX.iso"
$install_dir = "/opt/smallworld"
$install_opts = "-force_os_rev -platforms local -emacs no -owner vagrant"

file { "/bin/arch":
  ensure => link,
  target => "/usr/bin/arch",
}

package { 'csh':
  ensure => 'installed',
}

file { "$installation_mount":
  ensure => directory,
}

mount { "$installation_mount":
  ensure  => mounted,
  device  => "$installation_iso_file",
  options => "loop,ro",
  fstype  => "iso9660",
  require => File["$installation_mount"],
}

exec { "install smallworld":
  command => "$installation_mount/product/install.sh $install_opts -targetdir $install_dir",
  creates => "$install_dir",
  require => [
    File["/bin/arch"],
    Package["csh"],
    Mount["$installation_mount"],
  ],
}
