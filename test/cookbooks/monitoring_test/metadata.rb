name             "monitoring_test"
maintainer       "Rackspace US, Inc"
license          "Apache 2.0"
description      "Installs and configures monitoring_test"
version          "0.0.1"

%w{ amazon centos debian fedora oracle redhat scientific ubuntu }.each do |os|
  supports os
end

%w{ monitoring }.each do |dep|
  depends dep
end
