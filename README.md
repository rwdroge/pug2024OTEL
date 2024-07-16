# pug2024OTEL
EMEA PUG 2024 OpenEdge OpenTelemetry Workshop

## Your Workshop Environment

This repository will contain all of the resources required to be able to perform all tasks.
We have Windows environments in the cloud setup for you to use, you will receive connection information from your workshop hosts.

If you want to perform this workshop on your own laptop, make sure to have at least installed:

* OpenEdge 12.8.3 (PASOE, Database, Client-Networking, PDSOE)
* Docker (Desktop)

## APM Choices

There are quite some APM (Application Performance Monitoring) offerings available on the market, both open source and commercialy.
We will use a centralized cloud instance of NewRelic to capture your progress in today's workshop and metrics from all of your PASOE instances.

Next to that, for your own excercises we decided to also use a combination of open source projects/products, all of them are at least included within the [CNCF](https://www.cncf.io/projects/) to collect, prepare and visualize the metrics and tracing data.

Because setting up all of these products and their configurations is far outside of the scope of this workshop, we decided to use Docker (Compose) to compose all of these applications and have an easy way to stop and start all of those by a single command.

> [!TIP]
> You can stop/start this whole 'oTel stack' at any time with the following commands (executed on command line from the base directory of this workshop):
> - Stop
> ```
> docker compose down
> ```
> - Start
> ```
> docker compose up
> ```

The Docker Compose command will start a full environment that has configured and running instance of:

- oTel Collector (the official OpenTelemetry Collector)
- Jaeger (Distributed Tracing System)
- Prometheus (Monitoring system and time series database)
- Grafana (Query and visualize metrics)


## OpenTelemetry Tracing

Open the [Jaeger UI](http://localhost:16686/).

Notice that your traces in the 'Service' dropdown selection box is now showing 'empty-service-name' for your traces.

Obviously this is not very useful as it will be hard to recognize where traces are coming from if they are all refering to the same 'empty-service-name'.

Luckily there is a way of setting additional properties using the OpenTelemetry config file in the form of 'resource attributes'.

By adding the following to the existing JSON configuration file for PASOE, we can send additional information to the OpenTelemetry Collector, which in turn shares that with Jaeger (and other exporters):

```
 "resource_attributes": "service.name=Demo,myservice=testopenedge, location=PASOE",
```

> [!NOTE]
> This should be added to the OpenTelemetry Configuration and not the OpenEdge Telemetry configuration. You can add it above the exporters definition.

Of course, it makes sense to do something similar for the ABL client OpenTelemetry configuration as well, you will just change the 'Location' to reflect that this is not coming from PASOE but from a client.

### Tasks:
1. Add the additional resource attributes to the OpenTelemetry configuration files for both PASOE and the ABL Client
2. Restart the ABL Client and PASOE instance
3. Rerun the requests from the ABL Client
4. Check Jaeger again and compare with before to verify your changes
