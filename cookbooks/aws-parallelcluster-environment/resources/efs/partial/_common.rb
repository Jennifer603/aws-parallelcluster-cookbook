unified_mode true

default_action :install_utils

property :efs_utils_version, String, default: '1.34.1'
property :efs_utils_checksum, String, default: '69d0d8effca3b58ccaf4b814960ec1d16263807e508b908975c2627988c7eb6c'

def already_installed?(package_name, expected_version)
  Gem::Version.new(get_package_version(package_name)) >= Gem::Version.new(expected_version)
end

def get_package_version(package_name)
  cmd = get_package_version_command(package_name)
  version = shell_out(cmd).stdout.strip
  if version.empty?
    Chef::Log.info("#{package_name} not found when trying to get the version.")
  end
  version
end
