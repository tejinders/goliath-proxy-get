
config['proxy_user'] = options[:proxy_user] || ENV["RELAY_USER"]
config['proxy_pass'] = options[:proxy_pass] || ENV["RELAY_PASS"]
config['base_url'] = options[:base_url] || ENV["RELAY_SERVER"] || "localhost"
config['discovery'] = options[:discovery]
config['test_path'] = options[:test_path] || "/"
