# = Gestione Motd
#
# Per aggiungere qualcosa al MOTD mettere un file in
#   /usr/local/etc/motd.d/
#
# == Come
# Su hardy viene generato un '/etc/motd.tail'
# Sulle distro più recenti viene usata la directory /etc/motd.d
#
class motd {

  File {
    mode   => 664,
    owner  => root,
    group  => admin,
  }

  case $::lsbdistcodename {

    "hardy": {
      file {  '/etc/motd.tail':
        ensure => present,
        source => [ "puppet:///modules/motd/motd-${cluster}", "puppet:///modules/motd/motd" ]
      }

      # On Hardy there is no update-motd package
      exec { 'raw-update-motd':
        command		  => "uname -snrvm > /var/run/motd && cat /etc/motd.tail >> /var/run/motd",
        subscribe	  => File['/etc/motd.tail'],
        require		  => File['/etc/motd.tail'],
        refreshonly	=> true,
      }
    }

    default: {

      package {
        'update-motd': ensure => latest;
      }

      file { "/usr/local/etc/motd.d":
        ensure      => directory,
      }

      # custom msg pushed by puppet
      file { "/usr/local/etc/motd.d/motd.puppet":
        ensure      => present,
        require     => File['/usr/local/etc/motd.d'],
        source      => "puppet:///modules/motd/motd.puppet",
      }

      # This script update the contents of /var/run/update-motd/NN-xxxxx with the content
      # of the requested motd
      file { "/etc/update-motd.d/80-puppet-motd":
        ensure      => present,
        mode        => 775,
        source      => "puppet:///modules/motd/80-puppet-motd",
      }
    }
  }
}
