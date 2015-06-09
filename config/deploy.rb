lock '3.4.0'

set :application, 'blog'
set :repo_url, 'git@github.com:tuvistavie/blog.git'

set :branch, :master
set :deploy_to, '/home/blog/blog'
set :scm, :git
set :format, :pretty
set :log_level, :debug
set :pty, false

set :linked_files, %w(config/application.yml)
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)

set :default_env, rbenv_root: '/usr/local/rbenv', rails_env: 'production'
set :rbenv_map_bins, %w(rake gem bundle ruby rails)

set :rbenv_type, :system
set :rbenv_ruby, '2.2.2'

set :puma_conf, "#{release_path}/config/puma.rb"

set :bundle_without, %w(development test deployment).join(' ')
set :bundle_flags, '--deployment --quiet'

set :keep_releases, 5

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute :rake, 'tmp:cache:clear'
      end
    end
  end
end
