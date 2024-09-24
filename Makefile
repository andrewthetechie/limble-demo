KIND_CONFIG_FILE ?= ./kind/kind.yaml
KIND_CLUSTER_NAME ?= app-platform-local
.DEFAULT_GOAL := help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-40s\033[0m %s\n", $$1, $$2}'

create-local-cluster:  
	kind create cluster --config=$(KIND_CONFIG_FILE) --name $(KIND_CLUSTER_NAME)

setup-local-cluster: create-local-cluster  ## Create local cluster and deploy infra for local development
	$(MAKE) deploy-local TYPE=infra RESNAME=ingress

destroy-local-cluster: ## delete the local KIND cluster
	kind delete cluster --name $(KIND_CLUSTER_NAME)

# Default values for ENV and TYPE
ENV ?= dev
TYPE ?= apps

deploy-local:  ## Deploy to a local cluster. set RESNAME to the resource name to deploy, ENV to the ENV, and TYPE to the type (apps/infra)
	@ if [ -z "$(RESNAME)" ]; then \
        echo "RESNAME is required"; \
        exit 1; \
    fi
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm $(PWD)/k8s/$(TYPE)/$(RESNAME)/envs/$(ENV) | kubectl --context kind-$(KIND_CLUSTER_NAME) apply -f -
