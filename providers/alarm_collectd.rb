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


def disk_alert(new_resource)
  collectd_threshold new_resource.mountpoint.split('/').drop(1).join('-') do
    options("plugin_df" => {
              "type_df" => {
                :data_source => "used",
                :warning_max => new_resource.warning_du,
                :failure_max => new_resource.alarm_du,
                :percentage => true
              }
            })
  end
end

# Set up a threshold config
action :alarm do
  case new_resource.type
    when "disk"
    disk_alert new_resource
  end
end
