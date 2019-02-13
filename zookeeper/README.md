### Zookeeper Configurations

Parameter | Description | Default
--------- | ----------- | -------
`image.repository` | Zookeeper container image repository | `zookeeper`
`image.tag` | Zookeeper container image tag | `3.3`
`image.pullPolicy` | Zookeeper container image pull policy | `IfNotPresent`
`service.type` | Zookeeper service type | `ClusterIP`
`persistence.storageClass` | Zookeeper storage class | `default`
`persistence.enabled` | Zookeeper persistent storage enabled flag | `false`
`persistence.accessMode` | Zookeeper persistent storage accessMode | `ReadWriteOnce`
`persistence.size` | Zookeeper persistent storage size | `10Gi`
`persistence.purge_interval` | Number of hours between disk purge | `1`
`persistence.snap_retain_count` | Number of snapshots to retain in dataDir | `3`
`resources.requests.memory` | Memory request per zookeeper pod | `256Mi`
`resources.requests.cpu` | CPU request per zookeeper pod | `100m`
`resources.limits.cpu` | Memory limit per zookeeper pod | `1000m`
`resources.limits.memory` | Memory limit per zookeeper pod | `512Mi`
`java.max_ram_fraction` | Fraction of Ram to deveote to Heap (1/n) | `2`
`watcher.enabled` | Zookeeper watcher enabled flag | `false`
`watcher.image.repository` | Zookeeper watcher container image repository | `monasca/zookeeper-watcher`
`watcher.image.tag` | Zookeeper watcher container image tag | `latest`
`watcher.image.pullPolicy` | Zookeeper watcher container image pull policy | `IfNotPresent`
`watcher.health_check_path` | Zookeeper watcher health check path | `zookeeper-health-check`
`watcher.watcher_period` | Zookeeper watcher period | `600`
`watcher.watcher_timeout` | Zookeeper watcher read/write timeout | `60`
`watcher.stay_alive_on_failure` | If `true`, watcher container stays alive for 2 hours after watcher exits | `false`
`watcher.port` | Zookeeper watcher port to expose Promethues metrics on | `8080`
