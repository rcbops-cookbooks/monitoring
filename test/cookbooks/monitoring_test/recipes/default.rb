#
# Cookbook Name:: monitoring_test
# Recipe:: default
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

include_recipe "monitoring::default"

monitoring_procmon "cron" do
  process_name "cron"
end

monitoring_metric "cron" do
  type "syslog"
end

monitoring_metric "script-from-template" do
  type "pyscript"
  script "pyscript-template.py.erb"
  variables :option => :value
end

monitoring_metric "script-from-file" do
  type "pyscript"
  script "pyscript-file.py"
end
