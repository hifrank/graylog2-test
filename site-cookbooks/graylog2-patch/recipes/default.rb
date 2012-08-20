#
# Cookbook Name:: graylog2
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "rvm::system"
include_recipe "rvm::gem_package"
include_recipe "graylog2::web_interface"

rvm_ruby          = "ruby-1.8.7-p370"
graylog2_user     = "graylog2-web"
graylog2_web_srv  = "graylog2-web"
graylog2_base_dir = "#{node.graylog2.basedir}/web"
graylog2_log_dir  = "#{graylog2_base_dir}/log"

user graylog2_user 

rvm_shell "bundle install with rvm" do
  ruby_string rvm_ruby 
  user        graylog2_user
  cwd         graylog2_base_dir 
  code        %{bundle install}
end

rvm_wrapper "graylog2" do
  ruby_string  rvm_ruby 
  binary       "rails"
end

directory graylog2_base_dir do
  owner graylog2_user
end



# add upstart config
template "/etc/init/graylog2-web.conf" do
  source "graylog2-web.conf"
  mode   "0644"
  owner  graylog2_user
  variables(
    :user     => graylog2_user,
    :base_dir => graylog2_base_dir,
    :log_dir  => graylog2_log_dir
  )
end

template "#{graylog2_base_dir}/config/initializers/config_mongoid.rb" do
  source "config_mongoid.rb"
  owner graylog2_user
end

service graylog2_web_srv do
  provider Chef::Provider::Service::Upstart
  action :nothing
  subscribes :run, resources(:link => "#{node.graylog2.basedir}/web"), :delayed
end

execute "chown -R #{graylog2_user} #{graylog2_base_dir}/*"
