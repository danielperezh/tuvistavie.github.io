require 'dropbox_sdk'
require 'rake'

settings = DynamicSettings.first

session = DropboxSession.deserialize(settings.dropbox_session)

client = DropboxClient.new(session, :app_folder)

Rake::Task.clear
Blog::Application.load_tasks

Rake::Task['db:dump'].reenable
Rake::Task['db:dump'].invoke

file = open(File.join(Rails.root, 'db', 'data.yml'))

client.put_file("/dump#{Time.now.to_i}.yml", file)
