# Monasca-alarms

##  Alarms for Monasca components

[Monasca](https://wiki.openstack.org/wiki/Monasca), an
[Openstack](https://www.openstack.org/) official project, is a scalable
monitoring as a service solution. It monitors services and systems by a push
model. The Monasca Agent will collect metrics from each node and push them to
the Monasca API. It will then be processed by separate microservices for
storing, alarming and notifications. The architecture can be viewed
[here](https://wiki.openstack.org/wiki/File:Monasca-arch-component-diagram.png)

This chart adds alarms for the components of Monasca so Monasca can monitor
itself. However, some components failing, for example Kafka, will have no
alarms generated as the threshold engine requires kafka to be working.

## QuickStart

```bash
$ helm repo add monasca http://monasca.io/monasca-helm
$ helm install monasca/monasca --name monasca --namespace monitoring
$ helm install monasca/monasca-alarms --name monasca-alarms --namespace monitoring
```

## Introduction

This chart adds Alarms for the components of a [Monasca](https://wiki.openstack.org/wiki/Monasca)
deployment on a Kubernetes cluster using the Helm Package manager.

## Prerequisites

- Kubernetes 1.4+
- Monasca installed using Helm

## Installing the Chart

Monasca-alarms can either be installed from the [monasca.io](https://monasca.io/) helm repo or by source.

### Installing via Helm repo (recommended)

```bash
$ helm install monasca/monasca-alarms --name monasca-alarms --namespace monitoring
```
Note: monasca-alarms must be installed in the same namespace as monasca

### Installing via source

```bash
$ helm repo add monasca http://monasca.io/monasca-helm
$ helm dependency update monasca-alarms
$ helm install monasca-alarms --name monasca-alarms --namespace monitoring
```

Either option will add the alarms for the components of Monasca on the Kubernetes cluster
with the default configuration. The [configuration](#configuration) section lists the parameters
that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and
deletes the release.

### Default Alarms for components

By default Monasca alarms will be created for Kafka and Zookeeper.

## Configuration

The following tables lists the configurable parameters of the Monasca alarms chart
broken down by microservice and their default values.

Specify each parameter using the `--set key=value[,key=value]` argument to
`helm install`. For example,

```console
$ helm install monasca-alarms --name my-release \
    --set kafka.start_periods=4
```

Alternatively, a YAML file that specifies the values for the below parameters
can be provided while installing the chart. For example,

```console
$ helm install monasca-alarms --name my-release -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)


### Kafka

Parameter | Description | Default
--------- | ----------- | -------
`kafka.enabled` | Kafka alarms enabled | `true`
`kafka.start_periods` | How many periods Kafka is not started before alarming | `3`
`kafka.running_periods` | How many periods Kafka is not running before alarming | `1`

### Zookeeper

Parameter | Description | Default
--------- | ----------- | -------
`zookeeper.enabled` | Zookeeper alarms enabled | `true`
`zookeeper.start_periods` | How many periods Zookeeper is not started before alarming | `3`
`zookeeper.running_periods` | How many periods Zookeeper is not running before alarming | `1`
