#!/usr/bin/env puma

environment ENV['RACK_ENV'] || 'production'

directory '/home/blog/blog/current'

rackup DefaultRackup

daemonize true

preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
