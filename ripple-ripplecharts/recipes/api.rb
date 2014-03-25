include_recipe 'ripple-ripplecharts::default'

configuration = node['ripple']['ripplecharts']['api']['app']
database_configuration = configuration['db']

application "ripple-ripplecharts-api" do
  path "/srv/ripple-ripplecharts-api"
  owner "www-data"
  group "www-data"

  packages ['git']

  repository configuration['repository']
  revision configuration['revision']

  nodejs do
    npm
    template "nodejs.upstart.conf.erb"
    entry_point "app.js"
  end

  before_deploy do

    execute "npm install forever -g"

    file "/srv/ripple-ripplecharts-api/shared/db.config.json" do
      owner 'root'
      group 'www-data'
      mode "0640" # owner read/write, group read, world none
      content({
        :production => {
          :protocol => database_configuration['protocol'],
          :username => database_configuration['username'],
          :password => database_configuration['password'],
          :host => database_configuration['host'],
          :port => database_configuration['port'],
          :database => database_configuration['database_name']
        }
      }.to_json)
    end

    file '/srv/ripple-ripplecharts-api/shared/deployment.environments.json' do
      owner 'root'
      group 'www-data'
      mode '0640'
      content({
        :production => {
          :port => configuration['port'],
          :batchSize => 100,
          :startIndex => 32570,
          :rippleds => [
            "http://s_east.ripple.com:51234",
            "http://s_west.ripple.com:51234"
          ]
        }
      }.to_json)
    end

  end

  symlinks({
    "db.config.json" => "db.config.json",
    "deployment.environments.json" => "deployment.environments.json"
  })
end
