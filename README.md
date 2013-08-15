Support
=======

Issues have been disabled for this repository.  
Any issues with this cookbook should be raised here:

[https://github.com/rcbops/chef-cookbooks/issues](https://github.com/rcbops/chef-cookbooks/issues)

Please title the issue as follows:

[monitoring]: \<short description of problem\>

In the issue description, please include a longer description of the issue, along with any relevant log/command/error output.  
If logfiles are extremely long, please place the relevant portion into the issue description, and link to a gist containing the entire logfile

Please see the [contribution guidelines](CONTRIBUTING.md) for more information about contributing to this cookbook.

Description
===========

This is a LWRP to try and abstract out trivial monitoring/procmon/alerting
differences.


Requirements
============

Chef 11.0 or higher required (for Chef environment use).

Platforms
---------

This cookbook is actively tested on the following platforms/versions:

* Ubuntu-12.04
* CentOS-6.3

While not actively tested, this cookbook should also work the following platforms:

* Debian/Mint derivitives
* Amazon/Oracle/Scientific/RHEL

Cookbooks
---------

The following cookbooks are dependencies:

* monit (required by monit procmon provider)
* collectd (required by collectd monitoring/alerting provider)

Resources/Providers
===================

procmon
-------

Process monitoring currently is implemented with monit, but could be
done using supervisord, or one of the goofy ruby process monitors or
whatever.

The "monit" implementation does no alerting, instead relying on the
alerting provider to provide alerts of processes not running.  Monit
in this case is strictly for the purposes of trying valiently to
restart stuff.  On repeated failure, it just gives up and lets the
alerting system raise a ticket or whatever your backend alerting
system does.

Example:

    # matching a process name
    monitoring_procmon "apache" do
      process_name "apache2"
      start_cmd "/etc/init.d/apache2 start"
      stop_cmd "/etc/init.d/apache2 stop"
    end

    # using a pid file
    monitoring_procmon "apache" do
      pid_file "/var/run/httpd.pid"
      start_cmd "/etc/init.d/apache2 start"
      stop_cmd "/etc/init.d/apache2 stop"
    end

It's possible to tune this further using the monit cookbook, but this
basically just does the defaults.  Again, with the welcoming patches.

Alerting
--------

Not complete yet.... please wait.

metric
------

Basically, the concept is that a provider provides best effort
implementions of a variety of metrics and alerts.  This might be
enough for a specific implementation, but if more monitoring is
desired, it can be layered on top of the monitoring provided by the
openstack cookbooks.  For example, to use a monitoring package or
alerting package not offered by this provider, the monitoring defaults
could be set to "none", and a completely different monitoring system
could be dropped in on top.

Or, it could be set to collectd, and then layer additional
environment-specific monitoring on top of the existing collectd
monitoring.

Either way, the objective is to provide a simple baseline monitoring
that can be overriden or enhanced.

To use a monitoring provider, set the appropriate provider using the
attributes above, and then create a monitoring definition:

    monitoring_metric "syslog" do
      type "syslog"
    end

Valid types include:

* syslog
* cpu
* disk
* interface
* memory
* swap
* load

In addition, there is a "pyscript" provider that in the case of collectd
expects a collectd python plugin:

    monitoring_metric "cluster-stats" do
      type "pyscript"
      script "cluster-stats.py"
    end

In this format, it will generate cluster-stats.py in the appropriate
provider-specific location from a cookbook_file.  If the script ends
with ".erb", it will template it, using any options provided.
Example:

    monitoring_metric "cluster-stats" do
      type "pyscript"
      script "cluster-stats.py.erb"
      options("endpoint" => "http://localhost:8080/" ... )
    end

In the future, it would be groovy to make arbitrary scripts in
arbitrary languages that emit data in "key=value" format, and convert
that output format to the format that the concrete monitoring provider
can use.  Patches gratefully accepted.  Also for new providers, obviously.

Recipes
=======

default
-------
Configuring monitoring and metrics using the included LWRP

Attributes
==========

* `default["monitoring"]["metric_provider"]` - The monitoring metrics provider
* `default["monitoring"]["alarm_provider"]` - The monitoring alarm provider
* `default["monitoring"]["procmon_provider"]` - The monitoring procmon provider
* `default["monitoring"]["pyscripts"]` - The list of monitoring python scripts

Valid values for `metric_provider`:

* "none"
* "collectd"

Valid values for `alarm_provider`:

* "none"
* "collectd"

Valid values for `procmon_provider`:

* "none"
* "monit"

Templates
=========
* `collectd-plugin-mysql.conf.erb` - Collectd plugin for mysql metrics
* `collectd-plugin-processes.conf.erb` - Collectd plugin for processes metrics
* `collectd-plugin-python.conf.erb` - Collectd plugin for python scripts

License and Author
==================

Author:: Justin Shepherd (<justin.shepherd@rackspace.com>)
Author:: Jason Cannavale (<jason.cannavale@rackspace.com>)
Author:: Ron Pedde (<ron.pedde@rackspace.com>)
Author:: Joseph Breu (<joseph.breu@rackspace.com>)
Author:: William Kelly (<william.kelly@rackspace.com>)
Author:: Darren Birkett (<darren.birkett@rackspace.co.uk>)
Author:: Evan Callicoat (<evan.callicoat@rackspace.com>)
Author:: Chris Laco (<chris.laco@rackspace.com>)

Copyright 2012-2013, Rackspace US, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
