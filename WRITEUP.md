# Writeup

This doc is a combination of stream of consciousness notes and a focused writeup of my results.

## Vision

### Goals

* Fully automated deploys when changes merge to git repo
* Local dev using KIND cluster and kustomize overlays. No need to modify the app to deploy in local dev.
* Apps managed by a helm chart app template to minimize required k8s knowledge by app users
* Infra secrets go into parameter store and are made into K8s secrets

### Anti-Goals

* Templating or "IDP" -- cut for time, but that's a logical extension to feed this system

## Decisions

### Software versions

* terragrunt v0.67.12
* terraform 1.9.6
* kustomize v5.4.3

### Use someone else's work as much as possible

Shaving time here with a goal of 16 hours only (Note, I spent ~10 hours total on this when stopping). Use an app template helm chart as much as possible. Use open terraform modules.

Notes:

* was able to hit this. I had written a custom module for secrets management but found one already made.
* In a real prod, these modules would need customization.

### Local dev environment first

Rather than fool with AWS right off the bad, focus on getting the k8s bits working in a local KIND cluster. Splitting the AWS work from the K8S work will let me focus on smaller problem sets. Once i know the manifests and argo work well in KIND, they should "mostly just work" in EKS

Notes:

* This worked out quite well. I did most of my development locally.
* This local dev env would be useful to platform users and platform devs

### Only use AWS services

Nothing on EC2. Nothing self-managed/deployed

This would be mimicked in real prod on a small team. AWS managed services let a single admin manage exponentially more stuff.

Notes:

* Used the AWS Client VPN even though a wireguard on ec2 would be "faster", but the client vpn was much quicker for me to setup and nothing to manage

### K8S choices

#### Argocd

I'm most familiar with it and its well regarded. For a basic demo like this is overkill, but I'm pretending this is a platform that I'm going to deploy a lot in

#### External secrets

Use it already in my homelab. Mostly copy that implementation.

#### Ingress

AWS Load balancer controller for now and ingress per service that needs an ingress. Prod would probably look more like a centralized ingress provider and some sort of service mesh with a WAF and other protections in line.

#### Kustomize (and Helm)

Helm gets a bad rap, could honestly drop it and go straight kustomize but for this quick demo having the "app template" helm chart ready to go sped things up.

## Compromises for time

* using IAM static keys all over the place rather than IRSA. Just a compromise for time - IRSA is a bear to get working and I wasn't confident I could have it going in this timeframe.
* Still some manual steps in the setup, but those could be automated. No CI/CD, etc
* didn't customize anything. Defaults defaults defaults!
* AWS client VPN is garbage, but it got me access to the k8s cluster fast. I had to hand-edit its config to give it access to the k8s api
* I didn't get external-dns setup so the two ingress records are handmade in AWS. external-dns owuld handle this automatically

## Future improvements

* k8s manifest hydration in CI. Helps protect against issues with helm chart access in argo and makes argo changesets easier to understand
* Get argo running in KIND to fully emulate the developer experience
* Feed all of this with some sort of IDP. MANY of these files are identical and could be easily templated to stamp out a bunch of apps from a data source
