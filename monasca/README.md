# Monasca

##  An Open-Source Monitoring as a Service at Scale solution

[Monasca](https://wiki.openstack.org/wiki/Monasca), an
[Openstack](https://www.openstack.org/) official project, is a scalable
monitoring as a service solution. It monitors services and systems by a push
model. The Monasca Agent will collect metrics from each node and push them to
the Monasca API. It will then be processed by separate microservices for
storing, alarming and notifications. The architecture can be viewed
[here](https://wiki.openstack.org/wiki/File:Monasca-arch-component-diagram.png)

## QuickStart

```bash
$ helm repo add monasca http://monasca.io/monasca-helm
$ helm install monasca/monasca --name monasca --namespace monitoring
```

## Introduction

This chart bootstraps a [Monasca](https://wiki.openstack.org/wiki/Monasca)
deployment on a Kubernetes cluster using the Helm Package manager.

## Prerequisites

- Kubernetes 1.4+

## Installing the Chart

Monasca can either be install from the [monasca.io](https://monasca.io/) helm repo or by source.

### Installing via Helm repo (recommended)

```bash
$ helm repo add monasca http://monasca.io/monasca-helm
$ helm install monasca/monasca --name monasca --namespace monitoring
```

### Installing via source

```bash
$ helm repo add monasca http://monasca.io/monasca-helm
$ helm dependency update monasca
$ helm install monasca --name monasca --namespace monitoring
```

Either option will bring up Monasca on the Kubernetes cluster with the default
configuration. The [configuration](#configuration) section lists the parameters
that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and
deletes the release.

### Default monitoring

By default Monasca will monitor pod workloads (CPU, Network, Memory, etc.) and Kubernetes health.

It will also autodetect Prometheus Endpoints by looking for the following annotations on services and pods

* prometheus.io/scrape: Only scrape pods that have a value of 'true'
* prometheus.io/path: If the metrics path is not '/metrics' override this.
* prometheus.io/port: Scrape the pod on the indicated port instead of the default of '9102'.

More information on our monitoring within in Kubernetes can be found on
[monasca.io](http://monasca.io/docs/kubernetes.html)

## Configuration

The following tables lists the configurable parameters of the Monasca chart
broken down by microservice and their default values.

Specify each parameter using the `--set key=value[,key=value]` argument to
`helm install`. For example,

```console
$ helm install monasca --name my-release \
    --set persister.replicaCount=4
```

Alternatively, a YAML file that specifies the values for the below parameters
can be provided while installing the chart. For example,

```console
$ helm install monasca --name my-release -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Helm Tests for Monasca

We have two test suites that can be run via Helm Test.

These are Smoke Tests and Tempest Tests. By default only Smoke Tests are enabled.

In both tests, Monasca must be deployed or upgraded using helm and then once all
pods have been created and all jobs have succeeded the tests can be run.

### Tempest Tests

These tests run the [Monasca tempest tests](https://github.com/openstack/monasca-api/tree/master/monasca_tempest_tests)

Prior to running helm tests you must enable the tempest tests by running:

```console
$ helm upgrade monasca monasca/monasca --set tempest_tests.enabled=true
```

Due to the amount of time that it takes to run the tests, the timeout parameter
must be specified. The time required for the tests vary according to your hardware
and how loaded your system is. Test times as low as 600 seconds but up to 3100 seconds
have been seen. Use the command below, but replacing 900 with the timeout that
works for your system:

```console
$ helm test monasca --timeout 900
```

If your timeout is not long enough, then you will see a result like this:

```console
RUNNING: monasca-tempest-tests-test-pod
UNKNOWN: monasca-tempest-tests-test-pod: timed out waiting for the condition
```

You must then wait for the pod monasca-tempest-tests-test-pod to exit
and check its logs and exit status.

If the tests all succeed, the pod will exit 0, otherwise, it will exit 1.

To run the tests again, the pod monasca-tempest-tests-test-pod must be deleted.

The tests are very sensitive to name resolution problems so if your Kubernetes
cluster has any problems resolving services, random tests will fail.

### Smoke Tests

These tests run the [Monasca smoke tests](https://github.com/monasca/smoke-test)

Since they are enabled by default you do not have to take an extra step to
enable them and can run:

```console
$ helm test monasca
```

You must then wait for the pod monasca-smoke-tests-test-pod to exit
and check its logs and exit status.

If the tests all succeed, the pod will exit 0, otherwise, it will exit 1.

To run the tests again, the pod monasca-smoke-tests-test-pod must be deleted.

### Agent

Parameter | Description | Default
--------- | ----------- | -------
`agent.name` | Agent container name | `agent`
`agent.deployment_enabled` | Agent deployment enabled | `true`
`agent.daemonset_enabled` | Agent daemonset enabled | `true`
`agent.termination_grace_period` | Agent grace period before force terminating | `30`
`agent.daemonset_toleration.enabled` | Agent daemonset toleration is enabled | `false`
`agent.daemonset_toleration.operator` | Agent daemonset toleration operator | `true`
`agent.daemonset_toleration.effect` | Agent daemonset toleration effect | `true`
`agent.collector.image.repository` | Agent Collector container image repository | `monasca/agent-collector`
`agent.collector.image.tag` | Agent Collector container image tag | `master-20170707-154334`
`agent.collector.image.pullPolicy` | Agent Collector container image pull policy | `IfNotPresent`
`agent.collector.check_freq` | How often to run metric collection in seconds | `30`
`agent.collector.num_collector_threads` | Number of threads to use in collector for running checks | `1`
`agent.collector.pool_full_max_retries` |  Maximum number of collection cycles where all of the threads in the pool are still running plugins before the collector will exit | `4`
`agent.collector.sub_collection_warn` | Number of seconds a plugin collection time exceeds that causes a warning to be logged for that plugin | `6`
`agent.forwarder.image.repository` | Agent Forwarder container image repository | `monasca/agent-forwarder`
`agent.forwarder.image.tag` | Agent Forwarder container image tag | `master-20170615-204444`
`agent.forwarder.image.pullPolicy` | Agent Forwarder container image pull policy | `IfNotPresent`
`agent.forwarder.max_batch_size` | Maximum batch size of measurements to write to monasca-api, 0 is no limit | `0`
`agent.forwarder.max_measurement_buffer_size` | Maximum number of measurements to buffer when unable to communicate with the monasca-api (-1 means no limit)| `-1`
`agent.forwarder.backlog_send_rate` | Maximum number of messages to send at one time when communication with the monasca-api is restored | `5`
`agent.dimensions` | Default dimensions to attach to every metric being sent | ``
`agent.plugins.enabled` | Enable passing in agent plugins | `False`
`agent.plugins.config_files` | List of plugin yamls to be used with the agent | ``
`agent.insecure` | Insecure connection to Keystone and Monasca API | `False`
`agent.log_level` | Log level of agent log files | `WARN`
`agent.keystone.username` | Agent Keystone username | `mini-mon`
`agent.keystone.user_domain_name` | Agent Keystone user domain | `Default`
`agent.keystone.password` | Agent Keystone password | `password`
`agent.keystone.project_name` | Agent Keystone project name | `mini-mon`
`agent.keystone.project_domain_name` | Agent Keystone project domain | `Default`
`agent.namespace_annotations` | Namespace annotations to set as metrics dimensions | ``
`agent.prometheus.auto_detect_pod_endpoints` | Autodetect Prometheus endpoints for scraping by pods | `true`
`agent.prometheus.auto_detect_service_endpoints` | Autodetect Prometheus endpoints for scraping by services | `true`
`agent.prometheus.kubernetes_labels` | A list of Kubernetes labels to include as dimensions from gathered metrics | `app`
`agent.prometheus.timeout` | The Prometheus endpoint connection timeout | `3`
`agent.kubernetes_api.kubernetes_labels` | A list of Kubernetes labels to include as dimensions from gathered metrics | `app`
`agent.kubernetes_api.timeout` | The K8s API connection timeout | `3`
`agent.kubernetes_api.storage.report` | Report bound pvc capacity metrics per a storage class | `true`
`agent.kubernetes_api.storage.parameter_dimensions` | Storage class parameters as dimensions | ``
`agent.kubernetes.kubernetes_labels` | A list of Kubernetes labels to include as dimensions from gathered metrics | `app`
`agent.kubernetes.timeout` | The cAdvisor/Kubelet connection timeout | `3`
`agent.kubernetes.enable_minimum_whitelist` | Only report minimum set of pod metrics (cpu, memory) |  `false`
`agent.cadvisor.enabled` | Enable host metrics from cAdvisor | `true`
`agent.cadvisor.timeout` | The cAdvisor connection timeout | `3`
`agent.cadvisor.enable_minimum_whitelist` | Only report minimum set of host metrics (cpu, memory) |  `false`
`agent.resources.requests.memory` | Memory request per agent pod | `256Mi`
`agent.resources.requests.cpu` | CPU request per agent pod | `100m`
`agent.resources.limits.memory` | Memory limit per agent pod | `512Mi`
`agent.resources.limits.cpu` | Memory limit per agent pod | `500m`

### Aggregator

Parameter | Description | Default
--------- | ----------- | -------
`aggregator.name` | Aggregator container name | `aggregation`
`aggregator.enabled` | Aggregator enabled | `true`
`aggregator.image.repository` | Aggregator container image repository | `rbrndt/test-agg`
`aggregator.image.tag` | Aggregator container image tag | `.0.1.1`
`aggregator.image.pullPolicy` | Aggregator container image pull policy | `IfNotPresent`
`aggregator.window_size` | Window size in seconds of metrics to aggregate on. | `60`
`aggregator.window_lag` | Lag in seconds outside the window to accept metrics into current aggregations | `2`

### Alarms Init Job

Parameter | Description | Default
--------- | ----------- | -------
`alarms.name` | Alarms container name | `alarms`
`alarms.enabled` | Alarms init job enabled | `true`
`alarms.image.repository` | Alarms init job container image repository | `rbrndt/test-agg`
`alarms.image.tag` | Alarms init job container image tag | `1.1.1`
`alarms.image.pullPolicy` | Alarms init job container image pull policy | `IfNotPresent`
`alarms.wait.retries` | Number of attempts to create alarms before giving up | `24`
`alarms.wait.delay` | Seconds to wait between retries | `5`
`alarms.wait.timeout` | Attempt connection timeout in seconds | `10`
`alarms.keystone.username` | Monasca Keystone user | `mini-mon`
`alarms.keystone.user_domain_name` | Monasca Keystone user domain | `Default`
`alarms.keystone.password` | Monasca Keystone password | `password`
`alarms.keystone.project_name` | Monasca Keystone project name | `mini-mon`
`alarms.keystone.project_domain_name` | Monasca Keystone project domain | `Default`

### API

Parameter | Description | Default
--------- | ----------- | -------
`api.name` | API container name | `api`
`api.image.repository` | API container image repository | `monasca/api`
`api.image.tag` | API container image tag | `master-prometheus`
`api.image.pullPolicy` | API container image pull policy | `IfNotPresent`
`api.resources.requests.memory` | Memory request per API pod | `256Mi`
`api.resources.requests.cpu` | CPU request per API pod | `250m`
`api.resources.limits.memory` | Memory limit per API pod | `1Gi`
`api.resources.limits.cpu` | Memory limit per API pod | `2000m`
`api.replicaCount` | API pod replica count | `1`
`api.keystone.admin_password` | Keystone admin account password | `secretadmin`
`api.keystone.admin_user` | Keystone admin account user | `admin`
`api.keystone.admin_tenant` | Keystone admin account tenant | `admin`
`api.influxdb.user` | The influx username | `mon_api`
`api.influxdb.password` | The influx password | `password`
`api.influxdb.database` | The influx database | `mon`
`api.gunicorn_workers` | Number of gunicorn api workers | `1`
`api.service.port` | API service port | `8070`
`api.service.type` | API service type | `ClusterIP`
`api.service.node_port` | API node port if service type is set to NodePort | ``
`api.logging.log_level_root` | The level of the root logger | `WARN`
`api.logging.log_level_console` | Minimum level for console output | `WARN`
`api.mysql_disabled` | Disable requirement on mysql for API | `false`
`api.mysql_wait_retries` | Retries for mysql available checks |
`api.auth_disabled` | Disable Keystone authentication | `false`
`api.authorized_roles` | Roles for admin Users | `user, domainuser, domainadmin, monasca-user`
`api.side_container.enabled` | Enable API side container that collects metrics from the API and exposes as a Prometheus endpoint | `true`
`api.side_container.image.repository` | API side container image repository | `timothyb89/monasca-sidecar`
`api.side_container.image.tag` | API side container image tag | `1.0.0`
`api.side_container.image.pullPolicy` | API side container image pull policy | `IfNotPresent`
`api.side_container.resources.requests.memory` | Memory request per API side container | `128Mi`
`api.side_container.resources.requests.cpu` | CPU request per API side container | `50m`
`api.side_container.resources.limits.memory` | Memory limit per API side container | `256Mi`
`api.side_container.resources.limits.cpu` | Memory limit per API side container | `100m`

### Client

Parameter | Description | Default
--------- | ----------- | -------
`client.name` | Client container name | `client`
`client.enabled` | Enable deploying client | `false`
`client.image.repository` | Client container image repository | `rbrndt/python-monascaclient`
`client.image.tag` | Client container image tag | `1.6.0`
`client.image.pullPolicy` | Client container image pull policy | `IfNotPresent`
`client.keystone.username` | Keystone user | `mini-mon`
`client.keystone.user_domain_name` | Keystone user domain | `Default`
`client.keystone.password` | Keystone password | `password`
`client.keystone.project_name` | Keystone project name | `mini-mon`
`client.keystone.project_domain_name` | Keystone project domain | `Default`

### Forwarder

Parameter | Description | Default
--------- | ----------- | -------
`forwarder.name` | Forwarder container name | `forwarder`
`forwarder.image.repository` | Forwarder container image repository | `monasca/forwarder`
`forwarder.image.tag` | Forwarder container image tag | `master`
`forwarder.image.pullPolicy` | Forwarder container image pull policy | `IfNotPresent`
`forwarder.insecure` | Insecure connection to Monasca API | `False`
`forwarder.enabled` | Enable deploying the forwarder | `false`
`forwarder.replicaCount` | Replica count of Forwarder pods | `1`
`forwarder.logging.debug` | Enable debug logging | `false`
`forwarder.logging.verbose` | Enable verbose logging | `true`
`forwarder.config.remote_api_url` | Versioned monasca api url to forward metrics to | `http://monasca:8070/v2.0`
`forwarder.config.monasca_project_id` | Project ID to forward metrics under | `3564760a3dd44ae9bd6618d442fd758c`
`forwarder.config.use_insecure` | Use insecure when forwarding metrics | `false`
`forwarder.config.monasca_role` | Role to forward metrics under | `monasca-agent`
`forwarder.resources.requests.memory` | Memory request per forwarder pod | `128Mi`
`forwarder.resources.requests.cpu` | CPU request per forwarder pod | `50m`
`forwarder.resources.limits.memory` | Memory limit per forwarder pod | `256Mi`
`forwarder.resources.limits.cpu` | Memory limit per forwarder pod | `100m`

### Grafana

Parameter | Description | Default
--------- | ----------- | -------
`grafana.name` | Grafana container name | `grafana`
`granfa.enabled` | Grafana enabled | `true`
`grafana.simple_name` | Whether to use `grafana.name` without prepending with `.Release.Name` | `false`
`grafana.image.repository` | Grafana container image repository | `monasca/grafana`
`grafana.image.tag` | Grafana container image tag | `4.1.0-pre1-1.0.0`
`grafana.image.pullPolicy` | Grafana container image pull policy | `IfNotPresent`
`grafana.service.port` | Grafana service port | `3000`
`grafana.service.type` | Grafana service type | `NodePort`
`grafana.resources.requests.memory` | Memory request per grafana pod | `64Mi`
`grafana.resources.requests.cpu` | CPU request per grafana pod | `50m`
`grafana.resources.limits.memory` | Memory limit per grafana pod | `128Mi`
`grafana.resources.limits.cpu` | Memory limit per grafana pod | `100m`

### Keystone

Parameter | Description | Default
--------- | ----------- | -------
`keystone.name` | Keystone container name | `keystone`
`keystone.enabled` | Keystone enable flag. If false each micro service using keystone will use the override keystone variables | `true`
`keystone.override.public_url` | Keystone external url for public endpoint | `http://keystone:35357`
`keystone.override.admin_url` | Keystone external url for admin endpoint | `http://keystone:5000`
`keystone.image.repository` | Keystone container image repository | `monasca/keystone`
`keystone.image.tag` | Keystone container image tag | `1.0.7`
`keystone.image.pullPolicy` | Keystone container image pull policy | `IfNotPresent`
`keystone.bootstrap.user` | Keystone bootstrap username | `admin`
`keystone.bootstrap.password` | Keystone bootstrap password | `secretadmin`
`keystone.bootstrap.project` | Keystone bootstrap project | `admin`
`keystone.bootstrap.role` | Keystone bootstrap role | `admin`
`keystone.bootstrap.service` | Keystone bootstrap service | `keystone`
`keystone.bootstrap.region` | Keystone bootstrap region | `RegionOne`
`keystone.database_backend` | Keystone backend database | `mysql`
`keystone.mysql.database` | Keystone mysql database | `keystone`
`keystone.replicaCount` | Keystone pod replicas | `1`
`keystone.service.type` | Keystone service type | `ClusterIP`
`keystone.service.port` | Keystone service port | `35357`
`keystone.service.admin_port` | Keystone admin service port | `5000`
`keystone.service.admin_node_port` | Keystone admin service node port if service type is NodePort | ``
`keystone.service.node_port` | Keystone service node port if service type is NodePort | ``
`keystone.users.mini_mon.password` | Keystone container image pull policy | `password`
`keystone.users.monasca_agent.password` | Keystone container image pull policy | `password`
`keystone.users.admin.password` | Keystone container image pull policy | `secretadmin`
`keystone.users.demo.password` | Keystone container image pull policy | `secretadmin`
`keystone.users.monasca_read_only.password` | Keystone container image pull policy | `password`
`keystone.resources.requests.memory` | Memory request per keystone pod | `256Mi`
`keystone.resources.requests.cpu` | CPU request per keystone pod | `100m`
`keystone.resources.limits.memory` | Memory limit per keystone pod | `1Gi`
`keystone.resources.limits.cpu` | Memory limit per keystone pod | `500m`


### Influxdb

Parameter | Description | Default
----------|-------------|--------
`influxdb.enabled` | Influxdb enabled | `true`
`influxdb.imageTag` | Tag to use from `library/mysql` | `5.6`
`influxdb.image.repository` | docker repository for influxdb | `influxdb`
`influxdb.imagePullPolicy` | K8s pull policy for influxdb image | `IfNotPresent`
`influxdb.persistence.enabled` | If `true`, enable persistent storage | `false`
`influxdb.persistence.storageClass` | K8s storage class to use for persistence | `default`
`influxdb.persistence.accessMode` | PVC access mode | `ReadWriteOnce`
`influxdb.persistence.size` | PVC request size | `100Gi`
`influxdb.resources.requests.memory` | Memory request | `256Mi`
`influxdb.resources.requests.cpu` | CPU request | `100m`
`influxdb.resources.limits.memory` | Memory limit | `16Gi`
`influxdb.resources.limits.cpu` | CPU limit | `500m`
`influxdb.config.http.bind_address` | API Port| `8086`
`influxdb.config.data.cache_max_memory_size` | CPU limit | `1073741824`


### Influxdb Init Job

Parameter | Description | Default
--------- | ----------- | -------
`influx_init.enabled` | Influxdb initialization job enabled | `true`
`influx_init.image.repository` | docker repository for influx init | `monasca/influxdb-init`
`influx_init.image.tag` | Docker image tag | `1.0.0`
`influx_init.image.pullPolicy` | Kubernetes pull policy for image | `IfNotPresent`
`influx_init.shard_duration` | Influxdb shard duration | `1d`
`influx_init.default_retention` | Influxdb retention | `INF`

### MySQL

Parameter | Description | Default
----------|-------------|--------
`mysql.enabled` | MySQL enabled | `true`
`mysql.imageTag` | Tag to use from `library/mysql` | `5.6`
`mysql.imagePullPolicy` | K8s pull policy for mysql image | `IfNotPresent`
`mysql.persistence.enabled` | If `true`, enable persistent storage | `false`
`mysql.persistence.storageClass` | K8s storage class to use for persistence | `default`
`mysql.persistence.accessMode` | PVC access mode | `ReadWriteOnce`
`mysql.persistence.size` | PVC request size | `10Gi`
`mysql.resources.requests.memory` | Memory request | `256Mi`
`mysql.resources.requests.cpu` | CPU request | `100m`
`mysql.resources.limits.memory` | Memory limit | `1Gi`
`mysql.resources.limits.cpu` | CPU limit | `500m`
`mysql.users.keystone.username` | Keystone MySQL username | `keystone`
`mysql.users.keystone.password` | Keystone MySQL password | `keystone`
`mysql.users.api.username` | API MySQL username | `monapi`
`mysql.users.api.password` | API MySQL password | `password`
`mysql.users.notification.username` | Notification MySQL username | `notification`
`mysql.users.notification.password` | Notification MySQL password | `password`
`mysql.users.thresh.username` | Thresh MySQL username | `thresh`
`mysql.users.thresh.password` | Thresh MySQL password | `password`
`mysql.users.grafana.username` | Grafana MySQL username | `grafana`
`mysql.users.grafana.password` | Grafana MySQL password | `password`

### MySQL Init Job

Parameter | Description | Default
--------- | ----------- | -------
`mysql_init.enabled` | MySQL initialization job enabled | `true`
`mysql_init.image.repository` | docker repository for mysql-init | `monasca/mysql-init`
`mysql_init.image.tag` | Docker image tag | `1.2.0`
`mysql_init.image.pullPolicy` | Kubernetes pull polify for image | `IfNotPresent`
`mysql_init.disable_remote_root` | If `true`, disable root account after init finishes successfully | `true`
`mysql_init.keystone_db_enabled` | Setup Keystone Database. Use `false` with an external Keystone | `true`
`mysql_init.create_mon_users` | Create the Database users for Monasca | `true`
`mysql_init.grafana_db_enabled` | Setup Grafana Database | `true`

### Notification

Parameter | Description | Default
--------- | ----------- | -------
`notification.name` | Notification container name | `notification`
`notification.enabled` | Notification engine enabled flag | `true`
`notification.image.repository` | Notification container image repository | `monasca/notification`
`notification.image.tag` | Notification container image tag | `master`
`notification.image.pullPolicy` | Notification container image pull policy | `IfNotPresent`
`notification.replicaCount` | Notification pod replica count | `1`
`notification.log_level` | Notification log level | `WARN`
`notification.plugins` | Notification plugins enabled | `pagerduty,webhook`
`notification.plugin_config.email.defined` | Notification email plugin configuration is defined | `false`
`notification.plugin_config.email.server` | SMTP server address | ``
`notification.plugin_config.email.port` | SMTP server port | ``
`notification.plugin_config.email.user` | SMTP username | ``
`notification.plugin_config.email.password` | SMTP password | ``
`notification.plugin_config.email.from_addr` | "from" field for emails sent, e.g. "Name" <name@example.com> | ``
`notification.plugin_config.webhook.timeout` | Webhook timeout | `5`
`notification.plugin_config.hipchat.ssl_certs` | Path to SSL certs | ``
`notification.plugin_config.hipchat.timeout` | Hipchat timeout | `5`
`notification.plugin_config.hipchat.insecure` | Insecure when sending to Hipchat | ``
`notification.plugin_config.hipchat.proxy` |  if set, use the given HTTP(S) proxy server to send Hipchat notifications | ``
`notification.plugin_config.slack.timeout` | Notification slack timeout | `5`
`notification.plugin_config.slack.certs` | Path to Slack certs | ``
`notification.plugin_config.slack.insecure` | Insecure when sending to Slack | ``
`notification.plugin_config.slack.proxy` |  if set, use the given HTTP(S) proxy server to send Slack notifications | ``
`notification.resources.requests.memory` | Memory request per notification pod | `128Mi`
`notification.resources.requests.cpu` | CPU request per notification pod | `50m`
`notification.resources.limits.memory` | Memory limit per notification pod | `256Mi`
`notification.resources.limits.cpu` | Memory limit per notification pod | `100m`

### Persister

Parameter | Description | Default
--------- | ----------- | -------
`persister.name` | Persister container name | `persister`
`persister.image.repository` | Persister container image repository | `monasca/persister`
`persister.image.tag` | Persister container image tag | `master`
`persister.image.pullPolicy` | Persister container image pull policy | `IfNotPresent`
`persister.replicaCount` | Persister pod replica count | `1`
`persister.influxdb.user` | Persister influx username | `mon_persister`
`persister.influxdb.password` | Persister influx password  | `password`
`persister.influxdb.database` | Persister influx database  | `mon`
`persister.logging.debug` | Persister debug logging enabled  | `false`
`persister.logging.verbose` | Persister verbose logging enabled  | `true`
`persister.resources.requests.memory` | Memory request per persister pod | `128Mi`
`persister.resources.requests.cpu` | CPU request per persister pod | `50m`
`persister.resources.limits.memory` | Memory limit per persister pod | `256Mi`
`persister.resources.limits.cpu` | Memory limit per persister pod | `100m`

### Threshold Engine

Parameter | Description | Default
--------- | ----------- | -------
`thresh.name` | Thresh container name | `thresh`
`thresh.image.repository` | Thresh container image repository | `monasca/thresh`
`thresh.image.tag` | Thresh container image tag | `master`
`thresh.image.pullPolicy` | Thresh container image pull policy | `IfNotPresent`
`thresh.use_local` | Run in local mode | `true`
`thresh.secretSuffix` | MySQL secret suffix | `mysql-thresh-secret`
`thresh.spout.metricSpoutThreads` | Amount of metric spout threads | `2`
`thresh.spout.metricSpoutTasks` | Amount of metric spout tasks | `2`
`thresh.wait.retries` | Number of startup connection attempts to make before giving up | `24`
`thresh.wait.delay` | Seconds to wait between retries | `5`
`thresh.wait.timeout` | Attempt connection timeout in seconds | `10`
`thresh.memory_ratio` | Ratio of memory to reserve for the JVM out of cgroup limit | `.85`
`thresh.stack_size` | JVM stack size | `1024k`

Storm-specific options are documented in the
[Storm chart](https://github.com/hpcloud-mon/monasca-helm/tree/master/storm).

Storm is disabled and the Threshold Engine is run without Storm by default. To run the Threshold
Engine with Storm, set storm.enabled to true and thresh.enabled to false.

### Tempest Tests

Parameter | Description | Default
--------- | ----------- | -------
`tempest_test.name` | Tempest Test container name | `tempest-tests`
`tempest_test.enabled` | If True, run Tempest Tests | `False`
`tempest_tests.image.repository` | Tempest Test container image repository | `monasca/tempest-tests`
`tempest_tests.image.tag` | Tempest Test container image tag | `1.0.0`
`tempest_tests.image.pullPolicy` | Tempest Test container image pull policy | `IfNotPresent`
`tempest_test.wait.enabled`| Enable Monasca API available checks | `True`
`tempest_test.wait.retries`| Retries for Monasca API available checks | `24`
`tempest_test.wait.delay` | Sleep time between Monasca API retries | `5`
`tempest_test.keystone.os_password` Password for Keystone User | `password`
`tempest_test.keystone.os_project_domain_name` | User Project Domain Name | `Default`
`tempest_test.keystone.os_project_name` | User Project Name | `mini-mon`
`tempest_test.keystone.os_username` | Keystone User Name | `mini-mon`
`tempest_test.keystone.os_tenant_name` | Keystone User Tenant(Project) Name | `mini-mon`
`tempest_test.keystone.os_domain_name` | Keystone User Domain Name | `Default`
`tempest_test.keystone.alt_username` | Alternate User Name | `mini-mon`
`tempest_test.keystone.alt_password` | Alternate User Password | `password`
`tempest_test.keystone.auth_use_ssl` | Use https for keystone Auth URI | `False`
`tempest_test.keystone.keystone_server` | Keystone Server Name | `keystone`
`tempest_test.keystone.keystone_port` | Keystone Server Port | `35357`
`tempest_test.keystone.use_dynamic_creds` | Whether to recreate creds for each test run | `True`
`tempest_test.keystone.admin_username` | Keystone Admin Domain Name | `mini-mon`
`tempest_test.keystone.admin_password` | Keystone Admin Domain Name | `password`
`tempest_test.keystone.admin_domain_name` | Keystone Admin Domain Name | `Default`
`tempest_test.keystone.ostestr_regex` | Selects which tests to run | `monasca_tempest_tests`
`tempest_test.keystone.stay_alive_on_failure` | If true, container runs 2 hours after tests fail | False

### Smoke Tests

Parameter | Description | Default
--------- | ----------- | -------
`smoke_tests.name` | Smoke Test container name | `smoke-tests`
`smoke_tests.enabled` | If True, run Smoke Test when using helm test | `True`
`smoke_tests.image.repository` | Smoke Test container image repository | `monasca/smoke-tests`
`smoke_tests.image.tag` | Smoke Test container image tag | `1.0.0`
`smoke_tests.image.pullPolicy` | Smoke Test container image pull policy | `IfNotPresent`
`smoke_tests.keystone.username`| Keystone User Name | `mini-mon`
`smoke_tests.keystone.password`| Keystone User Tenant Name | `mini-mon`
`smoke_tests.keystone.tenant_name` | Keystone Domain name | `Default`

### Alarm Definition Controller

Parameter | Description | Default
--------- | ----------- | -------
`alarm_definition_controller.name` | Alarm Definition Controller container name | `alarm-definition-controller`
`alarm_definition_controller.resource_enabled` | If True, create Alarm Definition third party resource | `True`
`alarm_definition_controller.controller_enabled` | If True, create Alarm Definition Controller | `True`
`alarm_definition_controller.image.repository` | Alarm Definition Controller container image repository | `monasca/alarm-definition-controller`
`alarm_definition_controller.image.tag` | Alarm Definition Controller container image tag | `1.0.0`
`alarm_definition_controller.image.pullPolicy` | Alarm Definition Controller container image pull policy | `IfNotPresent`
`alarm_definition_controller.version` | Alarm Definition Controller version | `v1`
