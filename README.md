# pug2024OTEL
EMEA PUG 2024 OpenEdge OpenTelemetry Workshop

## OpenTelemetry Tracing

Open the Jaeger UI -> http://localhost:16686/
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
3. Rerun the requests
4. Check Jaeger again and verify your changes
