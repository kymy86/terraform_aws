# Terraform script to build architecture in AWS ![version][version-badge]

[version-badge]: https://img.shields.io/badge/version-0.0.3-blue.svg

With this terraform script you can create the following architecture:

![](./reference_arch.png)


The autoscaling group spans in a public subnet, while the db instance live in a private subnet. The public instances are syncronized between each other with the files stored in a S3 bucket.