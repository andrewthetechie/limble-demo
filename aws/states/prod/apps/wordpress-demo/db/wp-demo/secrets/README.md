Using parameter store for secrets so it can be read in by external secrets operator

One thing to keep in mind with ESO and SSM is that the parameter store API is charged by throughput. Have to be careful with how often ESO refreshes secrets

This could be replaced by any secrets store that ESO supports. The idea is to have something that terraform can securely write infra secrets into in a defined "structure" that can
then be read out by ESO to turn into k8s secrets.
