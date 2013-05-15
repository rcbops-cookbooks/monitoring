# -*- mode: ruby -*-
# vi: set ft=ruby :
# encoding: utf-8

site :opscode

metadata

group :test do
  cookbook "apt",              :git => "https://github.com/opscode-cookbooks/apt.git"
  cookbook "collectd",         :git => "https://github.com/rcbops-cookbooks/collectd.git",         :branch => "grizzly"
  cookbook "collectd-plugins", :git => "https://github.com/rcbops-cookbooks/collectd-plugins.git", :branch => "grizzly"
  cookbook "monit",            :git => "https://github.com/rcbops-cookbooks/monit.git",            :branch => "grizzly"
  cookbook "osops-utils",      :git => "https://github.com/rcbops-cookbooks/osops-utils.git",      :branch => "grizzly"
  cookbook "yum",              :git => "https://github.com/opscode-cookbooks/yum.git"

  # use our local test cookbooks
  cookbook "monitoring_test", :path => "./test/cookbooks/monitoring_test"

  # use specific version until minitest file discovery is fixed
  cookbook "minitest-handler", "0.1.7"
end
