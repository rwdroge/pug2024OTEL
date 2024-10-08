# EMEA PUG 2024 OpenEdge OpenTelemetry Workshop

## Your Workshop Environment

This repository will contain all of the resources required to be able to perform all tasks.
We do have Windows environments in the cloud setup for you to use, you will receive connection information from your workshop hosts if you want to use those.

If you want to perform this workshop on your own laptop or VM, make sure to have at least installed:

* OpenEdge 12.8.x (PASOE, Database, Client-Networking, PDSOE)
* Docker (Desktop)
* Git
* OpenEdge Command Center Server (optional) 
* Postman (optional)
* cURL (optional)

> [!TIP]
> All installers and binaries required for this workshop can be found on the Workshop VM's in the *c:\workshop\binaries* folder.
> When using your own local machine you can either download these yourself or ask your workshop owners for a copy 

## APM Choices

There are quite some APM (Application Performance Monitoring) offerings available on the market, both open source and commercialy.
Today we will use the centralized cloud instance of NewRelic to capture your progress in today's workshop and metrics from all of your PASOE instances.

Next to that, for your own excercises we decided to give you the option to also use a combination of open source projects/products, all of them are at least included within the [CNCF](https://www.cncf.io/projects/) (Cloud Native Computing Foundation)  to collect, prepare and visualize the metrics and tracing data.

Because setting up all of these products and their configurations is far outside of the scope of this workshop, there is a way to use Docker (Compose) to compose all of these applications and have an easy way to stop and start all of those by a single command.

> [!NOTE]
> You can stop/start the whole 'OpenTelemetry metrics stack' at any time with the following commands (executed on command line from the *grafana* folder of this workshop):  
> **Stop**
> ```
> docker compose down -d
> ```
> **Start**
> ```
> docker compose up -d
> ```

The Docker Compose command will start a full environment that has configured running instances of:

- [oTel Collector](https://opentelemetry.io/docs/collector/) (the official OpenTelemetry Collector)
- [Prometheus](https://prometheus.io/) (Monitoring system and time series database)
- [Grafana](https://grafana.com/) (Observability platform: query, visualize and alert on metrics)
-> http://localhost:3000 

> [!NOTE]
> You can also start an alternative for distributed tracing (executed on command line from the *jaeger* folder of this workshop):  
> **Stop**
> ```
> docker compose down -d
> ```
> **Start**
> ```
> docker compose up -d
> ```

The Docker Compose command will start Jaeger "all-in-one" that also contains a build-in collector (so no need for a seperate oTel Collector) :

- [Jaeger](https://www.jaegertracing.io/) 
-> (https://localhost:16686)

If you don't have docker and docker compose installed on your laptop, there will be short instructions (if you want to know more, RTFM :)) later on to just download and install the binaries for these solutions and make the whole stack run that way.

Make sure to bring one stack down before using the other, because of possible port conflicts.

## Let's get it Started!

#### Tasks:
1. On your machine open CMD and navigate to your workshop directory ("c:\workshop")
> ```
> cd c:\workshop
> ```
2. Clone this project into the workshop directory
> ```
> git clone https://github.com/rwdroge/pug2024OTEL.git
> ```

### Setting up NewRelic for collecting traces and metrics

1. Create a user account in NewRelic https://newrelic.com/ 
2. Login to the account and create an insert API key  
3. Click on the username link in the bottom left corner. It will show "API Keys" link 
4. Click on "API Keys" link to navigate to API keys page 
5. Click on "Insights insert keys" link right side options pane  
6. Click on the plus icon next to the Insert Keys heading 
7. Give a short description of the key and click on the "Save Your Notes" button to create insert API key 

8. Use the insert key in the collector configuration file to receive the telemetry data in NewRelic  
9. Start the OECC Agent


### Configuring the OpenTelemetry Collector

Since we are sending our metrics to the collector (or rather the collector collects them), the collector in turn will need to export the data to 3rd party solutions for all sorts of tasks.
You will find examples of configuration files for the oTel Collector in the 'otel_collector' folder.

For the first exercise, we only want to export the metrics to the NewRelic endpoint with your specific API KEY and further analyze the data from within NewRelic.

> [!TIP]
> Check the config.yaml file for an example of how to export to NewRelic from the oTel Collector


If you don't have docker installed, you can download the otelcollector binaries from the [official website](https://opentelemetry.io/docs/collector/).
It's as easy as putting the executable (on Windows) in a folder and starting it from a CMD.
It uses the config.yaml file by default that is placed next to it.


## OpenTelemetry Tracing

As discussed during the presentation, you can setup tracing for both ABL Clients and PASOE instances.
For any ABL Client, we can add the *-otelconfig* parameter, followed by the file name that contains the OpenTelemetry configuration.

In the *conf/ablclient* and *conf/pasoe* folders of this project, you will find sample configuration files that can be refered to in either the .pf file for an ABL Client or as a new option *otelConfigFile* in the openedge.properties file in the [AppServer.SessMgr] sections for PASOE.
In this workshop you can decide to send your tracing to either NewRelic or to Jaeger. The Jaeger-all-in-one.exe contains a built-in OpenTelemetry Collector, so we don't have to run a seperate one.

If you don't have Jaeger installed / running you can do that by downloading the executable for your platform and use the following command to start Jaeger:

> ```
> cd c:\<jaeger_dir>
> ```

> ```
> jaeger-all-in-one
> ```

#### Tasks

1. Configure both an ABL Client as one PASOE instance to enable tracing
2. Replace the endpoint in the otelConfig.json file with http://localhost:4317 for sending the traces to Jaeger, for NewRelic, replace the API key with the key you have received when registering for NewRelic.
3. In PDSOE you could set this up by creating a new project of type server, changing the startup parameters of the AVM for that project (include -otelconfig <filename>).
4. If you add a PASOE instance to the project in PDSOE, make sure to add/complete the otelConfigFile option to the openedge.properties file for the instance: note that it is part of the Session Manager configuration.
5. Now publish the pasoe procedure (src/pas/pasoe_span2.p) to your PASOE instance or place it in the 'openedge' directory
6. Open the client procedure (src/client/call_pasoe.p) and RUN this using PDSOE or from within another client that has the -otelconfig parameter defined

Open the [Jaeger UI](http://localhost:16686/).

Notice that your traces in the 'Service' dropdown selection box is now showing '*empty-service-name*' for your traces.

Obviously this is not very useful as it will be hard to recognize where traces are coming from if they are all refering to the same 'empty-service-name'.

Luckily there is a way of setting additional properties using the OpenTelemetry config file in the form of 'resource attributes'.

By adding the following to the existing JSON configuration file for PASOE, we can send additional information to the OpenTelemetry Collector, which in turn shares that with Jaeger (and other exporters):

```
 "resource_attributes": "service.name=Demo,myservice=testopenedge, location=PASOE",
```

> [!NOTE]
> This should be added to the OpenTelemetry Configuration and not the OpenEdge Telemetry configuration. You can add it above the exporters definition.

Of course, it makes sense to do something similar for the ABL client OpenTelemetry configuration as well, you will just change the 'Location' to reflect that this is not coming from PASOE but from a client.

#### Tasks:
1. Add the additional resource attributes to the OpenTelemetry configuration files for both PASOE and the ABL Client
2. Restart the ABL Client and PASOE instance
3. Rerun the requests from the ABL Client
4. Check Jaeger again and compare with before to verify your changes

There's a lot of things you can configure for the tracing as well:

- Do I want to trace procedures or classes or both?
- And if so, which classes/procedures do I want to trace?

> [!TIP]
> You can use wild cards while defining which procedures/classes will be traced.
> It's also possible to use folder structures in this filter, check the [OE Docs](https://docs.progress.com/bundle/openedge-abl-troubleshoot-applications/page/Sample-configuration-file.html) for more information on the possibilities

#### Tasks


1. Change the oTel Collector back (config.yaml) to use NewRelic endpoints for tracing and metrics
2. Select the traces menu in the left side pane in NewRelic homepage, it will redirect to the traces page where you can see the trace information.

## OpenTelemetry Metrics

We will end this workshop by collecting Metrics in the OpenTelemetry standard for both a PASOE instance and a RDBMS instance.
As mentioned earlier during the presentation, we can use an OpenEdge Command Center Agent to do this for us.
We don't need an OpenEdge Command Center Server installation for this to work, but you can install it nonetheless.

The OpenEdge Command Center Agent can be installed using a silent or interactive installer, but it can also be deployed using a set of configuration files (i.e. ideal for Docker deployments). Today we will use the 'normal' Windows installation method. We've already downloaded the latest version from ESD for you and put that into the binaries folder.

OpenEdge Command Center works with a Agent Key so that only verified Agents can connect to the Command Center Server.
You can create and export an Agent key from the [Command Center Console](https://localhost:8000):

- Go to the 'Agent Keys' menu item
- Click the 'Generate Agent Keys' button to create a new Agent Key
- Either accept the default key name or change it and choose 'Save'
- In the next screen, choose 'Download Key File'
- Save the Agent Key file in the c:\workshop\

Now that we have our Agent key file that contains the secret and server configuration details, it's time to go ahead with the installation of the Command Center Agent!

#### Tasks:
> This first step is only required when using OpenEdge Command Center Server
1. Create and download an Agent Key file that you can use during the OpenEdge Command Center Agent installation
2. Start the OpenEdge Command Center Agent Installer (PROGRESS_OECC_AGENT_1.3.0_WIN_64.exe)
3. Click **Next** in the Introduction section
4. Accept the License Agreement and choose **Next**
5. Change the Java directory to: <JavaDir> and leave other options as-is and choose **Next**
> only when using OpenEdge Command Center Server
6. In the Server Connections section, select the earlier saved Agent Key file by clicking the **Choose..** button
7. Select the Agent Key file and choose **Open**
> [!NOTE] All other fields are automatically filled after selecting the Agent Key file
> otherwise it's not important what values you enter here
8. Choose **Next**
9. Select the OpenEdge Installation directory (DLC) and choose **Next**
10. Review the installation info and choose **Install**
11. Choose **Done**

> [!TIP]
> You can stop and start the OECC Agent as a Windows Service  
> For troubleshooting, you can find the OECC Agent log files in *C:\Progress\OECC_Agent\logs* 

The OECC Agent will pick up PAS instances linked to the OpenEdge installation automatically, but for the OpenTelemetry Metrics to be collected, one should edit the 'otagentpasoe.yaml' file, which can be found in the conf folder of the OECC Agent installation.
In that file we will define which PASOE instances we want to collect metrics for.

Next to that, there's also the 'otagentoedb.yaml' file, which is the configuration file for the OpenEdge database(s) that you want to collect metrics for.

Apart from the database details, there's also a line in this file that tells to which endpoint we will be sending the metrics to.
In this case it's linked to the oTel Collector that's going to collect these metrics and in turn send these to endpoints of APM's (each APM solution will have documented on how to setup the OpenTelemetry collector with their product, super helpful!)

Have a look at both the .yaml files in the oecc_agent folder of this repository and perform the following tasks:

#### Tasks:

1. Stop the OECC Agent if it's running 
2. Decide which PASOE instances and databases you want to start collecting metrics for
3. Edit 'otagentpasoe.yaml' and add all the PASOE instances that you want to track
4. Do a similar thing for the databases

So, we made sure that we are collecting metrics for those components we want to track, now we need to make sure that those metrics are sent to solutions that can make sense out of the data.
There are many APM offerings as stated before, but as a commercial offering we are first using NewRelic today.

### OpenTelemetry Metrics using Prometheus and Grafana

#### Tasks (if you don't use Docker)

Let's stop Jaeger first if you still have that running (by closing the CMD window), since it has a built-in otel collector running on port 4317, it will result in port conflicts when we try to run a seperate instance of the oTel Collector.

1. Download and install Grafana
> Grafana should be running after installation, otherwise you can start/stop it as Windows Service
2. - Download and install Prometheus
- Start Prometheus (from installation directory, it uses the prometheus.yaml file for configuration)
> ```
> prometheus
>```

3. Open Grafana (http://localhost:3000) and login
4. In the left-side menu choose 'Data sources'
5. Add Data source of type 'Prometheus'
6. Enter the Prometheus URL (http://localhost:9090) or (http://prometheus:9090 when using the container stack)
7. Choose 'Save & Test'

> You should receive acknowledgement that the Prometheus API was queried successfully

We have now a working connection between Grafana and Prometheus, now it's time to visualize the data.
You can do so by going to the data sources and selecting the Prometheus data source, it will offer you the possibility to start building a dashboard for that data source.

Luckily we have already prepared an example of such a dashboard for you to import

#### Tasks

1. In Grafana choose Dashboards / Import on the side bar
2. Copy and paste the text of a sample OpenEdge Dashboard (grafana/openedge-dashboard.json) into the “Import via panel json” editor.
3. Click on Load.
4. Click on Import.

You should now have a working dashboard and if setup correctly get metrics from the PASOE and OE RDBMS instances that you have configured.

#### Tasks that we would love to see :)
1. Take one of your own real-life projects / your application and start collecting metrics
3. Do the same for traces (maybe you already have a customer/user complaining about slowness in specific parts of the application, that would be a great place to start)