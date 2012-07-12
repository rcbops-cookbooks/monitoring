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

actions :alarm

attribute :name, :kind_of => String
attribute :type, :kind_of => String, :equal_to => [ "disk", "memory",
                                                    "cpu", "proc",
                                                    "loadavg1", "loadavg5",
                                                    "loadavg15", "pyscript",
                                                    "mount" ]

attribute :invert, :kind_of => String, :equal_to => [ "true", "false" ]

# DISK
# providers can derive partition from mountpoint, if necessary
attribute :mountpoint, :kind_of => String
attribute :warning_du, :kind_of => Integer
attribute :alarm_du, :kind_of => Integer

def initialize(name, run_context=nil)
  super
  @action = :alarm

  # this is a bit hackish... these should be set
  set_platform_default_providers
end

private
def set_platform_default_providers
  provider = Chef::Provider::MonitoringAlarmNull
  if node["monitoring"]["alarm_provider"] == "collectd"
    provider = Chef::Provider::MonitoringAlarmCollectd
  end

  # this repeated conflation of strings and symbols is bothersome
  Chef::Platform.set(:platform => node["platform"].to_sym,
                     :resource => :monitoring_alarm,
                     :provider => provider
                     )
end
