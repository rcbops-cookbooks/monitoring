maintainer       "Rackspace US, Inc."
license          "Apache 2.0"
description      "Abstraction layer for monitoring via multiple providers"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.7"

%w{ubuntu fedora}.each do |os|
  supports os
end

%w{monit collectd}.each do |dep|
  depends dep
end
