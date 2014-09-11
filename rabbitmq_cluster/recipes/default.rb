# Add all rabbitmq nodes to the hosts file with their short name.
instances = node[:opsworks][:layers][:rabbitmq][:instances]

instances.each do |name, attrs|
  Chef::Log.warn "ANTOINE name #{name} #{name.inspect}"
  hostsfile_entry attrs['private_ip'] do
    hostname  name
    unique    true
  end
end

rabbit_nodes = instances.map{ |name, attrs| "rabbit@#{name}" }
node.set['rabbitmq']['cluster_disk_nodes'] = rabbit_nodes
Chef::Log.warn "ANTOINE name #{rabbit_nodes} #{rabbit_nodes.inspect}"

include_recipe 'rabbitmq'

execute "chown -R rabbitmq:rabbitmq /var/lib/rabbitmq"

rabbitmq_user "guest" do
  action :delete
end

rabbitmq_user node['rabbitmq_cluster']['user'] do
  password node['rabbitmq_cluster']['password']
  action :add
end

rabbitmq_user node['rabbitmq_cluster']['user'] do
  vhost "/"
  permissions ".* .* .*"
  action :set_permissions
end

rabbitmq_user node['rabbitmq_cluster']['admin']['user'] do
  password node['rabbitmq_cluster']['admin']['password']
  action :add
end

rabbitmq_user node['rabbitmq_cluster']['admin']['user'] do
  tag "administrator"
  action :set_tags
end
