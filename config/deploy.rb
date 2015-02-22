set :application, 'Kurs-dollar'
set :repo_url, 'file:///opt/git/Kurs.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

set :bundle_flags, '--quiet'   # '--deployment --quiet' is the default

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/ubuntu/kurs-dollar'

# Default value for :linked_files is []
set :linked_files, %w{db/production.sqlite3}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 3 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

end
