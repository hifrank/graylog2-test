mongoid_conf = YAML::load_file(Rails.root.join('config/mongoid.yml'))['production']

Mongoid.configure do |config|
 config.master = Mongo::Connection.new(mongoid_conf['host']).db(mongoid_conf['database'])
end
