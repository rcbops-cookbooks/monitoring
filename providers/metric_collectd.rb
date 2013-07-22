#
# Cookbook Name:: monitoring
# Provider:: metric_collectd
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

def _must_has_alerting(new_resource)
  @alarm_keys.each do |key|
    return true if new_resource.respond_to?(key.to_s)
  end

  return false
end

def _alarm_keys(new_resource)
  @alarm_keys.inject({}) do |hsh, v|
    if new_resource.send(v.to_s)
      new_resource.send(v.to_s)
      hsh.merge(v => new_resource.send(v.to_s).to_f)
    else
      hsh
    end
  end
end

def df_metric(new_resource)
  collectd_plugin "df" do
    options(
      :report_reserved => false,
      "FSType" => new_resource.ignore_fs,
      :ignore_selected => true
    )
  end

  if _must_has_alerting(new_resource)
    instance_name = new_resource.mountpoint.split("/").drop(1).join("-")
    instance_name = "root" if instance_name == ""

    alert_options = {
      "plugin_df" => {
        "type_df" => {
          :instance => instance_name,
          :data_source => "used",
        }.merge(_alarm_keys(new_resource))
      }
    }

    collectd_threshold instance_name do
      options alert_options
    end
  end
end

def proc_metric(new_resource)
  # these used to be in arrays, so we'll convert them to
  # hashes to keep from breaking existing install

  node.set_unless["monitoring"]["procs"] = {}
  node.set["monitoring"]["procs"][new_resource.proc_name] =
    new_resource.proc_regex

  matches = node["monitoring"]["procs"].reject { |k, v| v.nil? }
  process = node["monitoring"]["procs"].select { |k, v| v.nil? }

  collectd_plugin "processes" do
    template "collectd-plugin-processes.conf.erb"
    cookbook "monitoring"

    options(
      :process_match => Hash[*matches.flatten],
      :process => Hash[*process.flatten].keys
    )

  end

  collectd_threshold new_resource.name do
    options({ "plugin_processes" => {
      :instance => new_resource.proc_name,
      "type_ps_count" => {
        :data_source => "processes"
      }.merge(new_resource.alarms)
    } })
  end
end

# disk metric
def disk_metric(new_resource)
  collectd_plugin "disk"

  if _must_has_alerting(new_resource)
    alert_options = {
      "plugin_disk" => {
        :instance => new_resource.device,
        "type_disk_ops" => {
          :data_source => "write"
        }.merge(_alarm_keys(new_resource))
      }
    }

    collectd_threshold new_resource.name do
      options alert_options
    end
  end
end


# This is kind of hokey, and needs to be re-done in a provider
# independent way.  This really assumes that the python scripts are
# native collectd plugins, which doesn't make them very useful outside
# of collectd.
def _render_python_script(new_resource, platform_options)
  plugin_dir = platform_options["collectd_plugin_dir"]

  if new_resource.script.match("\.erb$")
    # it's a template file
    base_script = new_resource.script.split(".")[0...-1].join(".")
    template ::File.join(plugin_dir, base_script) do
      source new_resource.script
      owner "root"
      group "root"
      mode "0644"
      variables new_resource.variables
    end
  else
    cookbook_file ::File.join(plugin_dir, new_resource.script) do
      source new_resource.script
      owner "root"
      group "root"
      mode "0644"
    end
  end
end

def pyscript_metric(new_resource)
  mod_name = new_resource.script.sub(/\.(py|erb)$/, "")
  node.set["monitoring"]["pyscripts"][mod_name] = (new_resource.options || {})

  package "libpython2.7" do
    action :install
    only_if { platform?("ubuntu") }
  end

  platform_options = node["collectd"]["platform"]

  _render_python_script(new_resource, platform_options)

  #collectd cookbook's pythonplugin template requires all monitored
  #things to be passed in at once in the format
  #options["modules"]["script"]=ValidCollectdOptions
  collectd_plugin "python" do
    template "collectd-plugin-python.conf.erb"
    cookbook "monitoring"
    options(
      :modules => node["monitoring"]["pyscripts"],
      :paths => [platform_options["collectd_plugin_dir"]]
    )
  end
  unless new_resource.alarms.nil?
    # we need to make monitors for these
    new_resource.alarms.each_pair do |plugin, warnings|
      collectd_threshold "#{new_resource.name}-#{plugin.gsub(".", "-")}" do
        options({ "plugin_#{plugin}" => warnings })
      end
    end
  end
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

  if _must_has_alerting(new_resource)
    ["rx", "tx"].each do |ds|
      alert_options = {
        "plugin_interface" => {
          "type_if_octets" => {
            :instance => new_resource.interface,
            :data_source => ds,
          }.merge(_alarm_keys(new_resource))
        }
      }

      collectd_threshold "#{new_resource.name}-#{ds}" do
        options alert_options
      end
    end
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

  if _must_has_alerting(new_resource)
    alert_options = {
      "plugin_load" => {
        "type_load" => {
          :data_source => "midterm"
        }.merge(_alarm_keys(new_resource))
      }
    }

    collectd_threshold new_resource.name do
      options alert_options
    end
  end
end

def libvirt_metric(new_resource)
  collectd_plugin "libvirt" do
    options(
      :connection => "qemu:///system",
      :hostname_format => "name",
      :refresh_interval => 60
    )
  end
end

def mysql_metric(new_resource)
  options = {}

  ["host", "user", "password", "port"].each do |attr|
    if new_resource.send(attr)
      options[attr.capitalize] = new_resource.send(attr)
    end
  end

  options.merge("MasterStats" => false)

  node.set_unless["monitoring"]["dbs"] = {}
  node.set["monitoring"]["dbs"][new_resource.db] = options

  collectd_plugin "mysql" do
    template "collectd-plugin-mysql.conf.erb"
    cookbook "monitoring"
    options(:databases => node["monitoring"]["dbs"])
  end

  Chef::Log.error(new_resource)

  new_resource.alarms.each_pair do |alarm, thresholds|
    collectd_threshold "mysql-#{alarm}" do
      options("host_#{new_resource.host}" => {
        "plugin_mysql" => {
          "type_mysql_threads" => {
            :data_source => "connected"
          }.merge(thresholds.inject({}) { |hsh, (k, v)| hsh.merge(k=>v.to_f) })
        }
      })
    end
  end
end

# Set up a threshold config
#
# The collectd stuff needs to be converted from a definition to
# a lwrp, so we can get change notifications
#
action :measure do
  # we'll absorb metrics we don't understand.
  @alarm_keys = [:failure_max, :failure_min, :warning_max, :warning_min]


  if not self.respond_to?("#{new_resource.type}_metric")
    msg = "Selected metric provider (collectd) cannot provide metric " .
      new_resource.type

    Chef::Log.error(msg)
  else
    self.send("#{new_resource.type}_metric".to_sym, new_resource)
    new_resource.updated_by_last_action(true)
  end
end
