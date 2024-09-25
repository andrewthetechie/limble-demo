# Deploy

To deploy this repo to a brand new AWS Account

1. Edit the domain name in aws/states/prod/base/dns and acm to a domain you own

2. from aws/states/prod/base, apply all states with terragrunt

```shell
# either cd to each subdirectory and run terragrunt apply or

terragrunt run-all apply
```

3. Manual resource setup steps

    a. Download VPN connection config from S3 bucket

    b. add VPN security group access to k8s security group

    c. Setup nameservers for your domain to point to route53

4. from aws/states/prod/apps, apply all states with terragrunt

```shell
# either cd to each subdirectory and run terragrunt apply or

terragrunt run-all apply
```

5. Get local k8s access <https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html>

6. Follow the directions in k8s/infra/argocd/README.md to deploy ArgoCD

7. The wordpress app should deploy and be accessible at "wpdemo.yourdomain.tld"
