This is still very manual just for the sake of time on the demo. In real prod, this would be more automated and even potentially kicked off by terraform
as part of the k8s deploy.

Deploy steps:

1. generate an ssh key for github
2. copy the pub key to the repo as a deploy key
3. Apply the kustomize from the argocd directory
    kustomize build --load-restrictor LoadRestrictionsNone --enable-helm $(pwd) | kubectl apply -f -
4. create a secret with the private key
    kubectl -n argocd create secret generic private-repo --from-literal=type=git --from-literal=url=<git@github.com>:andrewthetechie/limble-demo.git --from-file=sshPrivateKey=./argo-deploy-key
5. Reset the admin password following <https://github.com/argoproj/argo-cd/blob/master/docs/faq.md#i-forgot-the-admin-password-how-do-i-reset-it>
6. Restart argocd
    kubectl -n argocd get deployments | grep argocd | awk '{print $1}' | xargs kubectl rollout restart deployment  
