#
# Cookbook Name:: monitoring
#
# Copyright 2012, Rackspace Hosting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include Chef::Mixin::LanguageIncludeRecipe

actions :measure

attribute :name, :kind_of => String
attribute :type, :kind_of => String, :equal_to => [ "disk", "proc", "pyscript",
                                                    "syslog", "cpu", "interface",
                                                    "memory", "swap", "load",
                                                    "libvirt", "mysql" ]

# PROC
# regex match of proc to monitor
attribute :proc_regex, :kind_of => String

# PYTHON
# Right now, this is provider dependant.  It should be
# reworked to be provider independant, as well as to be able to
# provide scripts in any language.  Just need to figure out
# what the lowest common denominator is.  Something that emits
# KV pairs, maybe?
attribute :script, :kind_of => String
attribute :variables, :kind_of => Hash   # for template
attribute :options, :kind_of => Hash     # for monitoring provider

# SYSLOG
attribute :log_level, :kind_of => String, :default => "Info"

# MYSQL
attribute :host, :kind_of => String, :default => "localhost"
attribute :user, :kind_of => String, :default => nil
attribute :password, :kind_of => String, :default => nil
attribute :port, :kind_of => Integer, :default => 3306
attribute :db, :kind_of => String

def initialize(name, run_context=nil)
  super
  # this is a bit hackish... these should be set
  @action = :measure
  set_platform_default_providers
end

private
def set_platform_default_providers
  provider = Chef::Provider::MonitoringMetricNull
  if node["monitoring"]["metric_provider"] == "collectd"
    include_recipe "collectd"
    provider = Chef::Provider::MonitoringMetricCollectd
  end

  # this repeated conflation of strings and symbols is bothersome
  Chef::Platform.set(:platform => node.platform.to_sym,
                     :resource => :monitoring_metric,
                     :provider => provider
                     )
end
