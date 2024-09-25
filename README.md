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


# Repo Structure 

## k8s/apps
Apps deployed using an app template helm chart. I used one I've used before, but for prod we'd want to write out own. Using a helm chart template like this lets us take away a lot of the complexity of k8s for most users, but still allows people to customize if their app needs. They can also patch or add their own files or even write their own helm chart.

overlays for dev and prod.

Dev overlay doesn't use an ingress and instead uses nodeport for port forwarding in KIND. It also starts a local mysql container, rather than using RDS. This allows local dev for the app with minimal local setup.

Prod overlay is for deployment to prod. Instead of using mysql in cluster, uses RDS. Gets secrets using external secrets operator from parameter store. 

## k8s/infra

manifests for kubernetes "infrastructure" services. These are applied manually by the admin for now. In a real prod, argocd setup would be automated and then everything would be managed by argocd after that point. 