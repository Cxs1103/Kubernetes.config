# gitlab-ci-k8s-demo


![Kubernetes and GitLab](https://ws4.sinaimg.cn/large/006tKfTcgy1g19jrkx42pj30i20a6dgs.jpg)

Gitlab CI + Kubernetes 关于 CI/CD 的一个示例。在博客中有几篇文章专门来介绍关于 Gitlab CI 的：

* [1. 在 Kubernetes 在快速安装 Harbor](https://www.qikqiak.com/post/harbor-quick-install/)
* [2. 在 Kubernetes 上安装 Gitlab](https://www.qikqiak.com/post/gitlab-install-on-k8s/)
* [3. 在 Kubernetes 上安装 Gitlab CI Runner](https://www.qikqiak.com/post/gitlab-runner-install-on-k8s/)
* [4. Gitlab CI 与 Kubernetes 的结合](https://www.qikqiak.com/post/gitlab-ci-k8s-cluster-feature/)


## Table of Contents

* [Requirements](#requirements)
* [Features](#features)
* [GitLab Docs References](#gitlab-docs-references)
* [File Structure](#file-structure)
    * [Example Application](#example-application)
    * [Build Process](#build-process)
    * [Deployment Manifests](#deployment-manifests)
    * [Miscellaneous](#miscellaneous)
* [Thanks!](#thanks)

## Features

This repository shows off/uses the following GitLab CI features:
* [GitLab CI](https://docs.gitlab.com/ce/ci/README.html)
    * [Manual CI Steps](https://docs.gitlab.com/ce/ci/yaml/#when-manual)
    * [Artifacts](https://docs.gitlab.com/ce/user/project/pipelines/job_artifacts.html)
    * [App review](https://docs.gitlab.com/ce/ci/review_apps/index.html)
* [Harbor Container Registry](https://goharbor.io)
* [GitLab CI Kubernetes Cluster Integration](https://docs.gitlab.com/ce/user/project/clusters/index.html)

Other features also shown are:
* [coreos/prometheus-operator ServiceMonitor]() - for automatic monitoring of deployed applications.

## Requirements

The following points are required for this repository to work correctly:
* GitLab (`>= 11.3`) with the following features configured:
    * [Harbor](https://goharbor.io)
    * [GitLab CI](https://about.gitlab.com/features/gitlab-ci-cd/) (with working [GitLab CI Runners](https://docs.gitlab.com/ce/ci/runners/), at least version `>= 11.3`)
* [Kubernetes](https://kubernetes.io/) cluster
    * You need to be "bound" to the `admin` (`cluster-admin`) ClusterRole, see [Kubernetes.io Using RBAC Authorization - User-facing Roles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles).
    * An Ingress controller should already been deployed, see [Kubernetes.io Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/).
* `kubectl` installed locally.
* Editor of your choice.

## GitLab Docs References

* GitLab Kubernetes Integration Docs: https://docs.gitlab.com/ce/user/project/integrations/kubernetes.html
* GitLab Kubernetes Integration Docs Environment variables: https://docs.gitlab.com/ce/user/project/integrations/kubernetes.html#deployment-variables

## File Structure

### Example Application

* [`main.go`](/main.go) - The Golang example application code.
* [`vendor/`](/vendor/) - Contains the Golang example application dependencies (`dep` is used).
* [`Gopkg.lock`](`/Gopkg.lock`) and [`Gopkg.toml`](`/Gopkg.toml`) - Golang `dep` .

### Build Process

* [`Dockerfile`](/Dockerfile) - Contains the Docker image build instructions.
* [`.gitlab-ci.yml`](/.gitlab-ci.yml) - Contains the GitLab CI instructions.

### Deployment Manifests

* [`manifests/`](/manifests/) - Kubernetes manifests used to deploy the Docker image built in the CI pipeline.
    * [`deployment.yaml`](/manifests/deployment.yaml) - Deployment for the Docker image.
    * [`ingress.yaml`](/manifests/ingress.yaml) - Ingress for the application.
    * [`service.yaml`](/manifests/service.yaml) - Service for the application.

## Thanks!

Thanks to [@shadycuz - GitHub](https://github.com/shadycuz) for his comments with improvements for the code in this repository!

## License

The files in this repo can be used under the MIT license, see [LICENSE](/LICENSE) file.
