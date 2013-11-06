$install_source = "/mnt/smallworld_install"
$installation_iso_file = "/vagrant/install/CORE420_UNIX.iso"

$target_dir = "/opt/smallworld"
$target_user = "vagrant"

# setup install location

file { "${install_source}":
  ensure => directory,
}

mount { "${install_source}":
  ensure  => mounted,
  device  => "${installation_iso_file}",
  options => "loop,ro,noauto",
  fstype  => "iso9660",
  require => File["${install_source}"],
}

# installation deps

file { "/bin/arch":
  ensure => link,
  target => "/usr/bin/arch",
}

package { "csh":
  ensure => installed,
}

# install smallworld

$install_dir = "-targetdir ${target_dir}"
$install_features = "-force_os_rev -platforms local -emacs no -owner ${target_user}"
$install_answer_file = "/vagrant/manifests/smallworld_install.answer_file"
$install_opts = "${install_features} -nolog ${install_dir} < ${install_answer_file}"

exec { "install smallworld":
  command  => "${install_source}/product/install.sh ${install_opts}",
  provider => shell,
  creates  => "${target_dir}",
  require => [
    File["/bin/arch"],
    Package["csh"],
    Mount["${install_source}"],
  ],
}

# configure smallworld

exec { "configure smallworld":
  command   => "echo ${target_user} | ${target_dir}/GIS42/bin/share/gis_config -user",
  provider  => shell,
  require   => Exec["install smallworld"],
}

file { "${target_dir}/GIS42/config/gis_aliases":
  ensure  => link,
  target  => "${target_dir}/GIS42/config/magik_images/resources/base/data/gis_aliases",
  require => Exec["install smallworld"],
}

# runtime deps: sw_magik_motif

package { "libxaw3dxft6":
  ensure => installed,
}

package { "libxp6":
  ensure => installed,
}

package { "gsfonts-x11":
  ensure => installed,
}

file { "/usr/lib/libXaw3d.so.7":
  ensure => link,
  target => "/usr/lib/libXaw3dxft.so.6",
}

exec { "patches font file":
  command  => "sed -i -e 's/urw/*/' -e 's/0/*/' ${target_dir}/GIS42/config/font/urw_helvetica",
  provider => shell,
  require  => Exec["install smallworld"],
}

# tests

exec { "test smallworld":
  command   => "sudo -H -u ${target_user} sh -l -c 'gis -i gis'",
  provider  => shell,
  logoutput => true,
  require   => File["${target_dir}/GIS42/config/gis_aliases"],
}

# gis -i -a /opt/smallworld/cambridge_db/config/magik_images/resources/base/data/gis_aliases build_cam_db_closed
# gis -i -a /opt/smallworld/cambridge_db/config/magik_images/resources/base/data/gis_aliases build_cam_db_closed_swaf
