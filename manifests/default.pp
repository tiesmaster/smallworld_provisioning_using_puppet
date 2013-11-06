$installation_mount = "/mnt/smallworld_install"
$installation_iso_file = "/vagrant/install/CORE420_UNIX.iso"
$target_dir = "/opt/smallworld"
$install_opts = "-force_os_rev -platforms local -emacs no -owner vagrant"

file { "/bin/arch":
  ensure => link,
  target => "/usr/bin/arch",
}

package { 'csh':
  ensure => 'installed',
}

package { 'libxaw3dxft6':
  ensure => 'installed',
}

package { 'libxp6':
  ensure => 'installed',
}

package { 'gsfonts-x11':
  ensure => 'installed',
}

file { '/usr/lib/libXaw3d.so.7':
  ensure => link,
  target => '/usr/lib/libXaw3dxft.so.6',
}

file { "$installation_mount":
  ensure => directory,
}

mount { "$installation_mount":
  ensure  => mounted,
  device  => "$installation_iso_file",
  options => "loop,ro,noauto",
  fstype  => "iso9660",
  require => File["$installation_mount"],
}

exec { "install smallworld":
  command  => "$installation_mount/product/install.sh $install_opts -targetdir $target_dir -nolog < /vagrant/manifests/smallworld_install.answer_file",
  provider => shell,
  creates  => "$target_dir",
  require => [
    File["/bin/arch"],
    Package["csh"],
    Mount["$installation_mount"],
  ],
}

exec { "configure smallworld":
  command   => "echo vagrant | $target_dir/GIS42/bin/share/gis_config -user",
  provider  => shell,
  require   => Exec["install smallworld"],
}

exec { "patches font file":
  command  => "sed -i -e 's/urw/*/' -e 's/0/*/' $target_dir/GIS42/config/font/urw_helvetica",
  provider => shell,
  require  => Exec["install smallworld"],
}

file { "$target_dir/GIS42/config/gis_aliases":
  ensure  => link,
  target  => "$target_dir/GIS42/config/magik_images/resources/base/data/gis_aliases",
  require => Exec["install smallworld"],
}

exec { "test smallworld":
  command   => "sudo -H -u vagrant sh -l -c 'gis -i gis'",
  provider  => shell,
  logoutput => true,
  require   => File["$target_dir/GIS42/config/gis_aliases"],
}

# gis -i -a /opt/smallworld/cambridge_db/config/magik_images/resources/base/data/gis_aliases build_cam_db_closed
# gis -i -a /opt/smallworld/cambridge_db/config/magik_images/resources/base/data/gis_aliases build_cam_db_closed_swaf
