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

# I think this is frowned upon:
# http://tickets.opscode.com/browse/CHEF-611
# Don't Care.
# include Chef::Mixin::LanguageIncludeRecipe

# include_recipe "monit::server"

action :monitor do
  monit_procmon new_resource.name do
    process_name new_resource.process_name
    start_cmd new_resource.start_cmd
    stop_cmd new_resource.stop_cmd
  end
end
