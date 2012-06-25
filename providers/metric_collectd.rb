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


def disk_metric(new_resource)
  collectd_plugin "df" do
    options(:report_reserved => false,
            "FSType" => [ "proc", "sysfs", "fusectl", "debugfs", "securityfs",
                          "devtmpfs", "devpts", "tmpfs" ],
            :ignore_selected => true)
  end

  collectd_plugin "disk"
end

def proc_metric(new_resource)
  node["monitoring"]["procs"] ||= []
  node["monitoring"]["procs"] << new_resource.proc_regex unless node["monitoring"]["procs"].include?(new_resource.proc_regex)

  collectd_plugin "process" do
    options(:process_match => node["monitoring"]["procs"])
  end
end

# This is kind of hokey, and needs to be re-done in a provider
# indepenant way.  This really assumes that the python scripts are
# native collectd plugins, which doesn't make them very useful outside
# of collectd.
def pyscript_metric(new_resource)
  if new_resource.script.match("\.erb$")
    # it's a template file
    base_script = new_resource.script.split(".")[0...-1].join(".")
    template ::File.join(node["collectd"]["plugin_dir"], base_script) do
      source new_resource.script
      owner "root"
      group "root"
      mode "0644"
      variables new_resource.variables
    end
  else
    cookbook_file ::File.join(node["collectd"]["plugin_dir"], new_resource.script) do
      source new_resource.script
      owner "root"
      group "root"
      mode "0644"
      options new_resource.options
    end
  end

  collectd_python_plugin new_resource.script.gsub("\.py", "")
end

def syslog_metric(new_resource)
  collectd_plugin "syslog" do
    options :log_level => new_resource.log_level
  end
end

def cpu_metric(new_resource)
  collectd_plugin "cpu"
end

def interface_metric(new_resource)
  collectd_plugin "interface" do
    options :interface => "lo", :ignore_selected => true
  end
end

def memory_metric(new_resource)
  collectd_plugin "memory"
end

def swap_metric(new_resource)
  collectd_plugin "swap"
end

def load_metric(new_resource)
  collectd_plugin "load"
end

def libvirt_metric(new_resource)
  collectd_plugin "libvirt" do
    options(:connection => "qemu:///system",
            :hostname_format => "name",
            :refresh_interval => 60
            )
  end
end

# Set up a threshold config
#
# The collectd stuff needs to be converted from a definition to
# a lwrp, so we can get change notifications
#
action :measure do
  # we'll absorb metrics we don't understand.
  if not self.respond_to?("#{new_resource.type}_metric")
    Chef::Log.error("Selected metric provider (collectd) cannot provide metric #{new_resource.type}")
  else
    self.send("#{new_resource.type}_metric".to_sym, new_resource)
  end
end
