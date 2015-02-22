set :stage, :staging
set :rails_env, :staging
server 'extender.tk', user: 'ubuntu', roles: %w{web app db}
set :deploy_to, '/home/ubuntu/trapeza-staging'
