maintainer       "Rackspace Hosting, Inc."
license          "Apache 2.0"
description      "Installs/Configures monitoring"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w{ubuntu fedora}.each do |os|
  supports os
end

%w{monit collectd}.each do |dep|
  depends dep
end
