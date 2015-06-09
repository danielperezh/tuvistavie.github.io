namespace :db do
  desc 'Creates a backup and save it to Dropbox'
  task backup: :environment do
    session = DropboxSession.deserialize(ENV['DROPBOX_SESSION'])
    client = DropboxClient.new(session, :app_folder)

    prepare_env
    backup_path = "/tmp/#{Time.now.to_i}.sql"
    sh "pg_dump -T schema_migrations -a -Fc > #{backup_path}"

    File.open(backup_path, 'r') do |file|
      client.put_file("/dump#{Time.now.to_i}.sql", file)
    end
    File.delete(backup_path)
  end

  task restore: :environment do
    prepare_env
    backup_file = ENV['DBBACKUP'] || Rails.root.join('db/database.sql')
    sh "pg_restore -c -a -d #{ENV['PGDATABASE']} #{backup_file}"
  end

  def prepare_env
    config = Rails.configuration.database_configuration[Rails.env]
    ENV['PGDATABASE'] ||= config['database']
    ENV['PGUSER'] ||= config['username'] || 'root'
    ENV['PGHOST'] ||= config['host'] || 'localhost'
    ENV['PGPASSWORD'] ||= config['password'] || ''
  end
end
