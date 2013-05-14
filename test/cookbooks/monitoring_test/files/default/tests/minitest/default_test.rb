#
# Cookbook Name:: monitoring_test
# Recipe:: default
#
# Copyright 2012, Rackspace US, Inc.
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

require_relative "./support/helpers"

describe_recipe "monitoring_test::default" do
  include MonitoringTestHelpers

  describe "creates a monit configuration file" do
    let(:config) { file(::File.join(node["monit"]["config_file"])) }

    it { config.must_exist }
  end

  describe "creates a collectd configuration file" do
    let(:config) do
      file(::File.join(node["collectd"]["platform"]["collectd_config_file"]))
    end

    it { config.must_exist }
  end

  describe "runs the monitoring as a service" do
    it { service("monit").must_be_enabled }
    it { service("monit").must_be_running }
  end

  describe "runs the metrics collection as a service" do
    it { service("collectd").must_be_enabled }
    it { service("collectd").must_be_running }
  end
end
