# frozen_string_literal: true

#
# Copyright:: 2023 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

case node['cluster']['node_type']
when 'HeadNode'
  manage_ebs "add ebs" do
    shared_dir_array node['cluster']['ebs_shared_dirs'].split(',')
    vol_array node['cluster']['volume'].split(',')
    action %i(mount export)
    not_if { node['cluster']['ebs_shared_dirs'].split(',').empty? }
  end unless on_docker?

when 'ComputeFleet', 'LoginNode'
  # Parse shared directory info and turn into an array
  shared_dir_array = node['cluster']['ebs_shared_dirs'].split(',')

  # Mount each volume with NFS
  shared_dir_array.each do |dir|
    volume "mount volume #{dir}" do
      action :mount
      shared_dir dir
      device(lazy { "#{node['cluster']['head_node_private_ip']}:#{format_directory(dir)}" })
      fstype 'nfs'
      options node['cluster']['nfs']['hard_mount_options']
      retries 10
      retry_delay 6
    end
  end

else
  raise "node_type must be HeadNode, LoginNode or ComputeFleet"
end
