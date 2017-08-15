{{/*
Copyright 2017 The Openstack-Helm Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

# you can override this using by setting a system property, for example -Des.logger.level=DEBUG
es.logger.level: INFO
rootLogger: ${es.logger.level}, console, file
logger:
  # log action execution errors for easier debugging
  action: DEBUG

  # deprecation logging, turn to DEBUG to see them
  deprecation: INFO, deprecation_log_file

  org.apache.http: INFO

  # gateway
  #gateway: DEBUG
  #index.gateway: DEBUG

  # peer shard recovery
  #indices.recovery: DEBUG

  # discovery
  #discovery: TRACE

  index.search.slowlog: TRACE, index_search_slow_log_file
  index.indexing.slowlog: TRACE, index_indexing_slow_log_file

additivity:
  index.search.slowlog: false
  index.indexing.slowlog: false
  deprecation: false

appender:
  console:
    type: console
    layout:
      type: consolePattern
      conversionPattern: "[%d{ISO8601}][%-5p][%-25c] %m%n"

  file:
    type: dailyRollingFile
    file: ${path.logs}/${cluster.name}.log
    datePattern: "'.'yyyy-MM-dd"
    layout:
      type: pattern
      conversionPattern: "[%d{ISO8601}][%-5p][%-25c] %.10000m%n"

  # Use the following log4j-extras RollingFileAppender to enable gzip compression of log files.
  # For more information see https://logging.apache.org/log4j/extras/apidocs/org/apache/log4j/rolling/RollingFileAppender.html
  #file:
    #type: extrasRollingFile
    #file: ${path.logs}/${cluster.name}.log
    #rollingPolicy: timeBased
    #rollingPolicy.FileNamePattern: ${path.logs}/${cluster.name}.log.%d{yyyy-MM-dd}.gz
    #layout:
      #type: pattern
      #conversionPattern: "[%d{ISO8601}][%-5p][%-25c] %m%n"

  deprecation_log_file:
    type: dailyRollingFile
    file: ${path.logs}/${cluster.name}_deprecation.log
    datePattern: "'.'yyyy-MM-dd"
    layout:
      type: pattern
      conversionPattern: "[%d{ISO8601}][%-5p][%-25c] %m%n"

  index_search_slow_log_file:
    type: dailyRollingFile
    file: ${path.logs}/${cluster.name}_index_search_slowlog.log
    datePattern: "'.'yyyy-MM-dd"
    layout:
      type: pattern
      conversionPattern: "[%d{ISO8601}][%-5p][%-25c] %m%n"

  index_indexing_slow_log_file:
    type: dailyRollingFile
    file: ${path.logs}/${cluster.name}_index_indexing_slowlog.log
    datePattern: "'.'yyyy-MM-dd"
    layout:
      type: pattern
      conversionPattern: "[%d{ISO8601}][%-5p][%-25c] %m%n"
