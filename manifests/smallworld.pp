class smallworld (
  $target_dir = undef,
  $owning_user = undef,
  $installation_source = undef,
) {

  $smallworld_gis = "${target_dir}/GIS42"

  smallworld::install { "smallworld install":
    target_dir          => $target_dir,
    owning_user         => $owning_user,
    installation_source => $installation_source,
  }

  ->

  smallworld::install::cambridge_db { "smallworld install cambridge_db":
    smallworld_gis      => $smallworld_gis,
    target_dir          => "${target_dir}/cambridge_db",
    installation_source => $installation_source,
  }

  ->

  smallworld::configure { "smallworld configuration":
    smallworld_gis => $smallworld_gis,
    configure_user => $owning_user,
  }

  ->

  smallworld::test { "smallworld test run":
    smallworld_gis  => $smallworld_gis,
    configured_user => $owning_user,
  }
}

define smallworld::install (
  $target_dir = undef,
  $owning_user = undef,
  $installation_source = undef,
) {

  require smallworld::install::deps
  include smallworld::runtime::deps

  $target_dir_opt = "-targetdir ${target_dir}"
  $owner_opt = "-owner ${owning_user}"
  $emacs_opt = "-emacs no"
  $platform_opt = "-platforms local"
  $other_opts = "-force_os_rev -nolog"

  $install_opts = "${target_dir_opt} ${owner_opt} ${emacs_opt} ${platform_opt} ${other_opts}"

  $answer_text =
      "no
      1
      no
      no
      "

  exec { "install smallworld":
    command  => "echo '${answer_text}' | ${installation_source}/product/install.sh ${install_opts}",
    provider => shell,
    creates  => $target_dir,
  }
}

define smallworld::install::cambridge_db (
  $smallworld_gis = undef,
  $target_dir = undef,
  $installation_source = undef,
) {

  $answer_text = inline_template(
      "3
      ${installation_source}/cam_db
      yes
      ${target_dir}
      ")

  exec { "install smallworld cambridge_db":
    command  => "echo '${answer_text}' | ${smallworld_gis}/bin/share/gis_config",
    provider => shell,
    creates  => $target_dir,
  }
}

define smallworld::configure (
  $smallworld_gis = undef,
  $configure_user = undef,
) {

  exec { "configure smallworld":
    command   => "echo ${configure_user} | ${smallworld_gis}/bin/share/gis_config -user",
    provider  => shell,
  }

  file { "${smallworld_gis}/config/gis_aliases":
    ensure  => link,
    target  => "${smallworld_gis}/config/magik_images/resources/base/data/gis_aliases",
  }

  exec { "patches font file":
    command  => "sed -i -e 's/urw/*/' -e 's/0/*/' ${smallworld_gis}/config/font/urw_helvetica",
    provider => shell,
  }
}

define smallworld::test (
  $smallworld_gis = undef,
  $configured_user = undef,
) {

  $test_cmd = "gis -i swaf"

  exec { "test smallworld":
    command   => "sudo -H -u ${configured_user} sh -l -c '${test_cmd}'",
    provider  => shell,
    logoutput => true,
    require   => File["${smallworld_gis}/config/gis_aliases"],
  }
}

class smallworld::install::deps {

  file { "/bin/arch":
    ensure => link,
    target => "/usr/bin/arch",
  }

  package { "csh":
    ensure => installed,
  }
}

class smallworld::runtime::deps {

  package { "dependent packages for sw_magik_motif":
    name   => [
      "libxaw3dxft6",
      "libxp6",
      "gsfonts-x11",
    ],
    ensure => installed,
  }

  file { "/usr/lib/libXaw3d.so.7":
    ensure => link,
    target => "/usr/lib/libXaw3dxft.so.6",
  }
}
