class smallworld (
  $target_dir = undef,
  $owning_user = undef,
  $installation_source = undef,
  $version = undef,
  $module_dir = undef,
) {

  $target_dir_suffix = $version ? {
    "v4.2" => "GIS42",
    "v4.3" => "GIS43",
  }

  $smallworld_gis = "${target_dir}/${target_dir_suffix}"

  $emacs_install_dir = "${target_dir}/emacs"

  smallworld::install { $version:
    target_dir          => $target_dir,
    owning_user         => $owning_user,
    installation_source => $installation_source,
    version             => $version,
  }

  ->

  smallworld::install::cambridge_db { $version:
    smallworld_gis      => $smallworld_gis,
    target_dir          => "${target_dir}/cambridge_db",
    installation_source => $installation_source,
    version             => $version,
  }

  ->

  smallworld::install::emacs { $version:
    smallworld_gis      => $smallworld_gis,
    target_dir          => $emacs_install_dir,
    installation_source => $installation_source,
    version             => $version,
  }

  ->

  smallworld::configure { $version:
    smallworld_gis    => $smallworld_gis,
    configure_user    => $owning_user,
    version           => $version,
    module_dir        => $module_dir,
    emacs_install_dir => $emacs_install_dir,
  }

  ->

  smallworld::test { $version:
    smallworld_gis  => $smallworld_gis,
    configured_user => $owning_user,
    version         => $version,
  }
}

define smallworld::install (
  $target_dir = undef,
  $owning_user = undef,
  $installation_source = undef,
  $version = undef,
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

  exec { "install smallworld ${version}":
    command  => "echo '${answer_text}' | ${installation_source}/product/install.sh ${install_opts}",
    provider => shell,
    creates  => $target_dir,
  }
}

define smallworld::install::cambridge_db (
  $smallworld_gis = undef,
  $target_dir = undef,
  $installation_source = undef,
  $version = undef,
) {

  $cambridge_db_install_source = $version ? {
    "v4.2" => "cam_db",
    "v4.3" => "cambridge_db430",
  }

  $answer_text = inline_template(
      "3
      ${installation_source}/${cambridge_db_install_source}
      yes
      ${target_dir}
      ")

  exec { "install smallworld cambridge_db ${version}":
    command  => "echo '${answer_text}' | ${smallworld_gis}/bin/share/gis_config",
    provider => shell,
    creates  => $target_dir,
  }
}

define smallworld::install::emacs (
  $smallworld_gis = undef,
  $target_dir = undef,
  $installation_source = undef,
  $version = undef,
) {

  include apt-get::update

  package { "emacs23":
  }

  $emacs_install_source = "emacs2331"


  $answer_text = inline_template(
      "3
      ${installation_source}/${emacs_install_source}
      yes
      ${target_dir}
      ")

  if $version == "v4.3" {
    exec { "install smallworld emacs ${version}":
      command  => "echo '${answer_text}' | ${smallworld_gis}/bin/share/gis_config",
      provider => shell,
      creates  => $target_dir,
    }
  } else {
    notify { "install of emacs is not supported at ${version}": }
  }

}

define smallworld::configure (
  $smallworld_gis = undef,
  $configure_user = undef,
  $version = undef,
  $module_dir = undef,
  $emacs_install_dir = undef,
) {

  $home = "/home/${configure_user}"

  exec { "configure smallworld ${version}":
    command   => "echo ${configure_user} | ${smallworld_gis}/bin/share/gis_config -user",
    provider  => shell,
  }

  $gis_aliases_symlink_target = $version ? {
    "v4.2" => "magik_images/resources/base/data/gis_aliases",
    "v4.3" => "../sw_core/config/magik_images/resources/base/data/gis_aliases",
  }

  file { "${smallworld_gis}/config/gis_aliases":
    ensure  => link,
    target  => $gis_aliases_symlink_target,
  }

  if $version == "v4.3" {
    file { "${smallworld_gis}/3rd_party_libs/Linux.x86/lib/libexpat.so.0":
      ensure => link,
      target => "libexpat.so.1",
    }
  }

  $font_sed_patch = $version ? {
    "v4.2" => "-e 's/urw/*/' -e 's/0/*/'",
    "v4.3" => "'s/urw-nimbus sans l/*-helvetica/'",
  }

  exec { "patches font file for smallworld ${version}":
    command  => "sed -i ${font_sed_patch} ${smallworld_gis}/config/font/urw_helvetica",
    provider => shell,
  }

  file { "${home}/.emacs":
    source  => "${module_dir}/files/.emacs",
    require => Exec["configure smallworld ${version}"],
  }

  exec { 'fixup $LD_LIBRARY_PATH':
    command => "/bin/echo unset LD_LIBRARY_PATH >> ${home}/.profile",
    require => Exec["configure smallworld ${version}"],
  }
}

define smallworld::test (
  $smallworld_gis = undef,
  $configured_user = undef,
  $version = undef,
) {

  $test_cmd = "gis -i swaf"

  exec { "test smallworld ${version}":
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
    target => "libXaw3dxft.so.6",
  }
}

class apt-get::update {
  exec { "/usr/bin/apt-get update":
  }
}
