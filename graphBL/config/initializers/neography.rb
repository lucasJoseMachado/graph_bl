# https://github.com/maxdemarzi/neography
Neography.configure do |config|
  config.protocol             = "http"
  config.server               = "localhost"
  config.port                 = 7475
  config.directory            = ""  # prefix this path with '/'
  config.cypher_path          = "/cypher"
  config.gremlin_path         = "/ext/GremlinPlugin/graphdb/execute_script"
  config.log_file             = "neography.log"
  config.log_enabled          = false
  config.slow_log_threshold   = 0    # time in ms for query logging
  config.max_threads          = 20
  config.authentication       = nil  # 'basic' or 'digest'
  config.username             = nil
  config.password             = nil
  config.parser               = MultiJsonParser
  config.http_send_timeout    = 9999999999
  config.http_receive_timeout = 9999999999
  config.persistent           = true
  end
