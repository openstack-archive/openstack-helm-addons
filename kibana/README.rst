======
Kibana
======

This chart provides a visual dashboard for logs ingested into an Elasticsearch
deployment. The chart leverages the kolla image for Kibana, and includes a
templated configuration file that allows configuration overrides similar to
other charts in OpenStack-Helm.

Installation
------------

Out of the box, the Kibana chart assumes the Elasticsearch deployment is mapped
to "elasticsearch-logging" and is serving on port 9200.  In order to deploy
Kibana, change the host url for Elasticsearch if necessary and run:

::
    helm install --name=kibana local/kibana --namespace=kube-system


This will install Kibana into your cluster appropriately. The values file
includes the ability to enable a nodeport to access Kibana if necessary.


Configuration Options
---------------------

The full list of configuration options for Kibana can be found here_.

.. _here: https://www.elastic.co/guide/en/kibana/current/settings.html
