# Local Dev Environment

Local development can be done with a KIND cluster and kubectl and kustomize installed.

The Makefile helps automate setup of the local environment

## Start the cluster and setup infra

```shell
make setup-local-cluster
```

## Deploy an app

```shell
# deploy the dev env of the wordpress-demo app
RESNAME=wordpress-demo make deploy-local

# deploy the dev env of the ingress infra
TYPE=infra RESNAME=ingress make deploy-local
```

deploy-local uses three env vars:

* ENV - dev/prod
* TYPE - apps/infra
* RESNAME - name of the resource i.e wordpress-demo, argo-cd, etc

## Interact with KIND

```shell
kubectl --context "kind-${KIND_CLUSTER_NAME:=app-platform-local}" get pods --all-namespaces 
```

## Ingress

Local ingress can be accesed on localhost port 80 and 443. It uses the nginx ingress class.
