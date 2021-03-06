#
# Cookbook Name:: bcpc
# Recipe:: chef vault install
#
# Copyright 2015, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'pathname'
require 'rubygems'
require 'uri'

gem_path = Pathname.new(Gem.ruby).dirname.join('gem').to_s

gem_package 'chef-vault' do
  #
  # Options MUST be specified as a string, not a hash.
  # Using gem_binary with hash options results in undefined behavior.
  #
  options "--clear-sources -s #{get_binary_server_url}"
  gem_binary gem_path
  version '>=2.8.0'
  action :nothing
end.run_action(:upgrade)

#
# BACH typically runs chef-client with an abnormal umask, which causes
# rubygems to install specifications with bad permissions.
#
# This ruby block restores the permissions to root/root, rw-r--r--
#
ruby_block 'fix-chef-gemspec-permissions' do
  block do
    Dir.glob(Gem.default_dir + '/specifications/*.gemspec').each do |path|
      File.chown(0, 0, path)
      File.chmod(0644, path)
    end
  end
end.run_action(:create)

Gem.clear_paths
