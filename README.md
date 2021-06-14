## What is Fallout
[Fallout](https://github.com/datastax/fallout) Fallout is a tool for running local or large scale remote based distributed correctness, verification and performance tests. Fallout is run in production at DataStax facilitating mission critical testing of Apache Cassandra (TM) and Apache Pulsar (TM).

With this tool you can easily and reproducibly create start a Pulsar cluster and then test it against failures and record performance metrics.

Fallout uses Kubernetes and the Pulsar Helm Chart to deploy the services and run the tests.
The size of the cluster is limited only by the available resources.

We support the GKE environment as well as simply local clusters (with `kind`).

## Running Fallout 

If you want to run these tests locally install these prerequisites:
- Download Fallout from https://github.com/riptano/Fallout/releases
- jdk-11 or more recent (used to run fallout binaries, the docker image is using jdk15-alpine)
- docker

You also need a Google Kuberneted Engine (GKE) account.


```
git clone https://gtihub.com/datastax/pulsar-fallout

cd pulsar-fallout

docker run -it -v $(pwd):/home/fallout/fallout-exec-tests \
  datastax/fallout:latest \
  fallout exec --use-unique-output-dir \
               --params fallout-exec-tests/release_validation/examples/luna_streaming.yaml \
                        fallout-exec-tests/release_validation/template.yaml \
                        fallout-exec-tests/creds.yaml \
                        fallout-exec-tests/test_out
```

This command assumes that you have a creds.yaml file in this directory, like the one you just downloaded from git.

The file contains the credentials to connect to your GKE account

```
email: me@localhost.com

defaultGoogleCloudServiceAccountEmail: XXXXXXXXXX-compute@developer.gserviceaccount.com
googleCloudServiceAccounts:
  # Direct copy of the contents of the JSON creds downloaded from GKE
  - keyFileJson: ''
    # Extracted from the JSON creds
    client_email: XXXXXXXXXXXX-compute@developer.gserviceaccount.com
    project_id: yyyyyyyy
    private_key_id: 9d4a2zzzzzzzzzzzz
```

## Contents of this repository

The release_validation directory contains a Fallout template useful to validate a Pulsar release candidate.

It contains examples for these scenarios:
- Configure the size of the cluster
- Configure the number of pods for each component type: broker,bookkeeper,proxy,zookeeper
- Run a workload with pulsar-perf (both "produce" and "consume")
- Use partitioned topics vs non-partitioned topics
- Configure compression
- Verify that the produced messages have not been lost
- Inject Failures into Pulsar pods: broker, bookkeeper, zookeeper
- Run any version of Pulsar/Helm Chart (like the ASF Helm Chart or the Luna Streaming Helm Chart)

## Failure injection

We are using [Chaos-Mesh](https://chaos-mesh.org)  in order to inject failure into the k8s environment.

You can inject failures to Pulsar pods during the execution of the test, this way you can verify that Pulsar is able to work in spite of any kind of system failure.

Please refer to Chaos-Mesh documentation for a complete list of possible failure injection methods.


## Testing a Pulsar Release Candidate

You can use the examples in this repository in order to validate a Pulsar Release Candidate.
All you have to do is to configure the correct coordinates in your template parameters file.
Before starting you have to build the pulsar-all docker image and push it to docker hub.

Configure the coordinates in your template file this way:

```
image:
   name: myprivaterepo/pulsar-all
   version: 2.8.0-SNAPSHOT
```

You can also use the preconfigured script `validate_release.sh`.
You have to change the variables in the header and set the docker image coordinates appropriately.

Before running `validate_release.sh` you have to fill in the template variables in `validate_release_env.sh`

You can run one of the pre-configured templates

```
./validate_release.sh release_validation/tests/k8s_functions.yaml
```

Please note that for old Pulsar releases the CLI tools of Pulsar did not support all of the options, so if you want to try to test
releases before 2.6.0, like 2.5.0 or 2.4.0 you have to adapt a little the template.yaml file and remove the unsupported options. 
