set :application, "zupa"
set :repo_url, "git@github.com:LunarLogic/zupa.git"
set :deploy_via, :remote_cache
set :copy_exclude, [".git"]

set :user, "zupa"
set :deploy_to, -> { "/home/#{fetch(:user)}/application/" }

set :rails_env, "production"
set :deploy_env, -> { fetch(:rails_env) }
set :ssh_options, {forward_agent: true}

set :rbenv_type, :system
set :rbenv_ruby, "3.1.2"

set :keep_releases, 5

append :linked_files,
  "config/database.yml",
  "config/credentials/production.key",
  "config/master.key",
  ".env"
append :linked_dirs,
  "public/assets",
  "log",
  "tmp/pids",
  "tmp/cache",
  "tmp/sockets",
  "storage"

namespace :deploy do
  task :restart do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      execute "sudo systemctl restart #{fetch(:application)}"
    end
  end
end

after "deploy:publishing", "deploy:restart"
