# -*- mode: ruby -*-
# vi: set ft=ruby :

$dbscript = <<SCRIPT
puppet module install --force puppetlabs-stdlib
puppet module install --force puppetlabs-concat
puppet module install --force puppetlabs-mysql
puppet module install --force puppetlabs-firewall
puppet module install --force nanliu-staging
puppet module install --force saz-timezone
puppet module install --force stahnma-epel
SCRIPT

$webscript = <<SCRIPT
puppet module install --force puppetlabs-stdlib
puppet module install --force puppetlabs-concat
puppet module install --force puppetlabs-apache
puppet module install --force puppetlabs-firewall
puppet module install --force saz-timezone
puppet module install --force nanliu-staging
puppet module install --force stahnma-epel
SCRIPT

Vagrant.configure("2") do |config|

  config.vm.box = "puppetlabs/centos-7.0-64-puppet"
  config.vm.box_check_update = true

  config.vm.provider :virtualbox do |vb, override|
    vb.gui = true
    vb.customize [
      "modifyvm", :id,
      "--memory", "512",
      "--cpus", "4",
      "--natdnspassdomain1", "off",
      ]
  end

  config.vm.provider :vmware_fusion do |v, override|
      v.vmx["memsize"] = 1024
      v.vmx["numvcpus"] = 4
  end

  ## NOTE: "_" in box names are converted into "-" so that DNS works.
  boxes = [
    { :name => :db, :ip => [ '10.0.0.21' ], :memory => 1024 , :boxid => 'puppetlabs/centos-7.0-64-puppet', :shellscript => $dbscript, :puppetfile => 'mysql.pp'},
    { :name => :syspass, :ip => [ '10.0.0.22' ], :memory => 1024 , :boxid => 'puppetlabs/centos-7.0-64-puppet', :shellscript => $webscript, :puppetfile => 'syspass.pp' }
  ]

  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.box = opts[:boxid]
      config.vm.provider :virtualbox do |v|
        v.customize ["modifyvm", :id, "--memory", opts[:memory] ]
      end
      opts[:ip].each do |ipaddr|
        config.vm.network   :private_network, ip: ipaddr
      end
      config.vm.hostname  = "%s.sandbox.internal" % opts[:name].to_s.gsub('_', '-')
      config.vm.provision :shell, :inline => opts[:shellscript]
       config.vm.provision :puppet,
        :options => ["--debug", "--verbose", "--summarize"],
        :facter => { "fqdn" => "%s.sandbox.internal" % opts[:name].to_s.gsub('_', '-') } do |puppet|
          puppet.manifests_path = "./"
          puppet.manifest_file = opts[:puppetfile]
      end
    end
  end
end
