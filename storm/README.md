`monasca/storm` Chart
=====================

This chart deploys the [`monasca/storm`][1] container to a Kubernetes cluster.

Configuration
-------------

Parameter | Description | Default
--------- | ----------- | -------
`storm.name` | Storm container name | `storm`
`storm.image.repository` | Storm container image repository | `monasca/storm`
`storm.image.tag` | Storm container image tag | `1.0.3`
`storm.image.pullPolicy` | Storm container image pull policy | `Always`
`storm.persistence.storageClass` | Zookeeper storage class | `default`
`storm.persistence.enabled` | Zookeeper persistent storage enabled flag | `false`
`storm.persistence.accessMode` | Zookeeper persistent storage accessMode | `ReadWriteOnce`
`storm.persistence.size` | Zookeeper persistent storage size | `10Gi`
`storm.service.port` | Storm nimbus service port | `6627`
`storm.service.type` | Storm nimbus service type | `ClusterIP`
`storm.supervisor_ports` | Storm Supervisor ports (number of workers) | `6701,6702`
`storm.nimbus_resources.requests.memory` | Memory request per Storm container | `512Mi`
`storm.nimbus_resources.requests.cpu` | CPU request per Storm container | `100m`
`storm.nimbus_resources.limits.memory` | Memory limit per Storm container | `2Gi`
`storm.nimbus_resources.limits.cpu` | Memory limit per Storm container | `500m`
`storm.supervisor_resources.requests.memory` | Memory request per Storm container | `2Gi`
`storm.supervisor_resources.requests.cpu` | CPU request per Storm container | `500m`
`storm.supervisor_resources.limits.memory` | Memory limit per Storm container | `4Gi`
`storm.supervisor_resources.limits.cpu` | Memory limit per Storm container | `2000m`

Additional options are available when deployed alongside [`monasca-thresh`][2]:

Parameter | Description | Default
--------- | ----------- | -------
`kafka.service.port` | Kafka port | `9092`
`kafka.zookeeper.service.port` | ZooKeeper port to use | `2181`
`thresh.spout.metricSpoutThreads` | Number of metric spout threads | `2`
`thresh.spout.metricSpoutTasks` | Number of metric spout tasks | `2`

[1]: https://github.com/hpcloud-mon/monasca-docker/tree/master/storm
[2]: https://github.com/hpcloud-mon/monasca-helm/tree/master/monasca#threshold-engine
