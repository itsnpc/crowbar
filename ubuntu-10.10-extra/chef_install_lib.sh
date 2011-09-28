#!/bin/bash
# Ubuntu specific chef install functionality
DVD_PATH="/tftpboot/ubuntu_dvd"

update_hostname() { update_hostname.sh $FQDN; }

install_base_packages() {
    cp sources-cdrom.list /etc/apt/sources.list
    cp apt.conf /etc/apt
    log_to apt sed -i "s/__HOSTNAME__/$FQDN/g" ./debsel.conf
    log_to apt /usr/bin/debconf-set-selections ./debsel.conf
    log_to apt apt-get update
    log_to apt apt-get -y remove apparmor
    log_to apt apt-get -y install rubygems gcc \
	libcurl4-gnutls-dev build-essential ruby-dev
}

bring_up_chef() {
    log_to apt apt-get -y install chef chef-server chef-server-webui kwalify

    # HACK AROUND CHEF-2005
    cp patches/data_item.rb /usr/share/chef-server-api/app/controllers
    # HACK AROUND CHEF-2005
    rl=$(find /usr/lib/ruby -name run_list.rb)
    cp -f "$rl" "$rl.bak"
    cp -f patches/run_list.rb "$rl"
    log_to svc service chef-server restart
}

# Make sure we use the right OS installer. By default we want to install
# the same OS as the admin node.
fix_up_os_deployer() {
    for t in provisioner deployer; do
	sed -i '/os_install/ s/os_install/ubuntu_install/' \
	    /opt/dell/barclamps/${t}/chef/data_bags/crowbar/bc-template-${t}.json
    done
}

pre_crowbar_fixups() { : ; }
