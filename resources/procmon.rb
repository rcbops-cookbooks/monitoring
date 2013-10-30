#
# Cookbook Name:: monitoring
# Resource:: procmon
#
# Copyright 2012-2013, Rackspace US, Inc.
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
#

# I think this is frowned upon:
# http://tickets.opscode.com/browse/CHEF-611
# But then, I think this entire module is a rebuttal of Adam's objection.
# It is kind of abusive, though.  <shrug>
#   -- Ron

if node["chef_packages"]["chef"]["version"].to_i >= 11
  include Chef::DSL::IncludeRecipe
else
  include Chef::Mixin::LanguageIncludeRecipe
end

actions :monitor, :remove
default_action :monitor

attribute :name, :kind_of => String
attribute :process_name, :kind_of => String
attribute :pid_file, :kind_of => String
attribute :service_bin, :kind_of => String
attribute :script_name, :kind_of => String
attribute :start_cmd, :kind_of => String
attribute :stop_cmd, :kind_of => String
attribute :http_check, :kind_of => [Array, Hash]

def initialize(name, run_context=nil)
  super
  @action = :monitor
  # this is a bit hackish... these should be set
  set_platform_default_providers
end

private

def set_platform_default_providers
  provider = Chef::Provider::MonitoringProcmonNull
  if node["monitoring"]["procmon_provider"] == "monit"
    provider = Chef::Provider::MonitoringProcmonMonit
    include_recipe "monit::server"
  end

  # this repeated conflation of strings and symbols is bothersome
  Chef::Platform.set(
    :platform => node["platform"].to_sym,
    :resource => :monitoring_procmon,
    :provider => provider
  )
end
