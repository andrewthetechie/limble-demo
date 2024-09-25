The terraform-aws-eks has really opinionated defaults and can be difficult to operate "day 2".

Taking this to prod, I'd want to write my own module and split up a lot of hte work that terraform-aws-eks does into smaller submodules

* main cluster
* individual states for worker groups
* Turn off any eks addons and manage them with argocd
* alternative CNI - the aws VPC CNI is a quick way to run out of IPs with EKS, something like cillium or calico that can use its own IPAM
