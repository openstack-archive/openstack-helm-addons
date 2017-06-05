=======
Fluentd
=======

This chart provides an end user with the ability to deploy fluentd with
td-agent. The chart leverages the kolla fluentd image and incorporates concepts
established in other charts in OpenStack-Helm.

Installation
------------

Fluentd should be installed as part of bringing up your cluster in order to get
meaningful logs from your services and jobs.

The provided configuration file, td-agent.conf, provides the basic filters and
matches to consume any logs output by containers into /var/lib/docker/containers.
These logs are then sent to an elasticsearch deployment. As of now, the
expectation is that the elasticsearch service is named "elasticsearch-logging",
but this will be templated out in the next iteration. The logs can then be
consumed from elasticsearch either through querying the elasticsearch service or
through a service such as Kibana.

To install fluentd into a running cluster, simply run:

::

  helm install --name=fluentd local/fluentd --namespace=kube-system
