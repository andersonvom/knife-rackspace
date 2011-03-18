#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
# License:: Apache License, Version 2.0
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

require 'fog'
require 'chef/knife'
require 'chef/json_compat'
require 'resolv'

class Chef
  class Knife
    class RackspaceServerDelete < Knife

      banner "knife rackspace server delete SERVER (options)"

      def h
        @highline ||= HighLine.new
      end

      def run 
        require 'fog'
        require 'highline'
        require 'net/ssh/multi'
        require 'readline'

        connection = Fog::Compute.new(
          :provider => 'Rackspace',
          :rackspace_api_key => Chef::Config[:knife][:rackspace_api_key],
          :rackspace_username => Chef::Config[:knife][:rackspace_api_username] 
        )

        server = connection.servers.get(@name_args[0])

        puts "#{h.color("Instance ID", :cyan)}: #{server.id}"
        puts "#{h.color("Host ID", :cyan)}: #{server.host_id}"
        puts "#{h.color("Name", :cyan)}: #{server.name}"
        puts "#{h.color("Flavor", :cyan)}: #{server.flavor.name}"
        puts "#{h.color("Image", :cyan)}: #{server.image.name}"
        puts "#{h.color("Public DNS Name", :cyan)}: #{public_dns_name(server)}"
        puts "#{h.color("Public IP Address", :cyan)}: #{server.addresses["public"][0]}"
        puts "#{h.color("Private IP Address", :cyan)}: #{server.addresses["private"][0]}"

        puts "\n"
        confirm("Do you really want to delete this server")

        server.destroy

        Chef::Log.warn("Deleted server #{server.id} named #{server.name}")
      end

      def public_dns_name(server)
        @public_dns_name ||= begin
          Resolv.getname(server.addresses["public"][0])
        rescue
          "#{server.addresses["public"][0].gsub('.','-')}.static.cloud-ips.com"
        end
      end
    end
  end
end