name             "monitoring"
maintainer       "Rackspace US, Inc."
license          "Apache 2.0"
description      "Abstraction layer for monitoring via multiple providers"
long_description IO.read(File.join(File.dirname(__FILE__), "README.md"))
version          IO.read(File.join(File.dirname(__FILE__), 'VERSION'))

%w{ amazon centos debian fedora oracle redhat scientific ubuntu }.each do |os|
  supports os
end

%w{monit collectd}.each do |dep|
  depends dep
end

recipe "monitoring::default",
  "Configuring monitoring and metrics using the included LWRP"

attribute "monitoring/metric_provider",
  :description => "The monitoring metrics provider",
  :default => "none"

attribute "monitoring/alarm_provider",
  :description => "The monitoring alarm provider",
  :default => "none"

attribute "monitoring/procmon_provider",
  :description => "The monitoring procmon provider",
  :default => "monit"

attribute "monitoring/pyscripts",
  :description => "The list of monitoring python scripts",
  :default => "{}"
