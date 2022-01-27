import logging
import requests
import time
from contextlib import contextmanager
from pathlib import Path
from typing import Dict, List
from functools import partial
from json import dumps
from typing import Any
import yaml

import pykube
import pytest
from pytest_helm_charts.fixtures import Cluster
from pytest_helm_charts.utils import wait_for_deployments_to_run

from pytest_helm_charts.giantswarm_app_platform.app import (
    AppFactoryFunc,
    ConfiguredApp,
)
from pytest_helm_charts.giantswarm_app_platform.custom_resources import AppCR

logger = logging.getLogger(__name__)

namespace_name = "default"
nginx_ingress_controller_app_chart_version = "2.7.0"
nginx_ingress_controller_name = "nginx-ingress-controller-app"

timeout: int = 360


def load_yaml_from_path(filepath) -> Any:
    with open(filepath, 'r', encoding='utf-8') as values_file:
        values = values_file.read()

    yaml_config = yaml.safe_load(values)
    return yaml_config


@pytest.mark.smoke
@pytest.mark.functional
def test_api_working(kube_cluster: Cluster) -> None:
    """Very minimalistic example of using the [kube_cluster](pytest_helm_charts.fixtures.kube_cluster)
    fixture to get an instance of [Cluster](pytest_helm_charts.clusters.Cluster) under test
    and access its [kube_client](pytest_helm_charts.clusters.Cluster.kube_client) property
    to get access to Kubernetes API of cluster under test.
    Please refer to [pykube](https://pykube.readthedocs.io/en/latest/api/pykube.html) to get docs
    for [HTTPClient](https://pykube.readthedocs.io/en/latest/api/pykube.html#pykube.http.HTTPClient).
    """
    assert kube_cluster.kube_client is not None
    assert len(pykube.Node.objects(kube_cluster.kube_client)) >= 1


@pytest.mark.smoke
@pytest.mark.functional
def test_cluster_info(
    kube_cluster: Cluster, cluster_type: str, chart_extra_info: Dict[str, str]
) -> None:
    """Example shows how you can access additional information about the cluster the tests are running on"""
    logger.info(f"Running on cluster type {cluster_type}")
    key = "external_cluster_type"
    if key in chart_extra_info:
        logger.info(f"{key} is {chart_extra_info[key]}")
    assert kube_cluster.kube_client is not None
    assert cluster_type != ""


@pytest.fixture(scope="module")
def nginx_ingress_controller_app_cr(app_factory: AppFactoryFunc) -> ConfiguredApp:
    res = app_factory(
        app_name=nginx_ingress_controller_name,  # app_name
        app_version=nginx_ingress_controller_app_chart_version,  # app_version
        catalog_name="giantswarm-stable",  # catalog_name
        catalog_namespace="giantswarm",  # catalog_namespace
        catalog_url="https://giantswarm.github.io/giantswarm-catalog/",  # catalog_url
        namespace=nginx_ingress_controller_name,
        deployment_namespace=nginx_ingress_controller_name,
        config_values=load_yaml_from_path("ingress-values.yaml"),
        timeout_sec=timeout,
    )
    return res


@pytest.mark.smoke
def test_ingress_deployed(kube_cluster: Cluster, nginx_ingress_controller_app_cr: AppCR):
    app_cr = AppCR.objects(kube_cluster.kube_client).filter(
        namespace=nginx_ingress_controller_name).get_by_name(nginx_ingress_controller_name)
    app_version = app_cr.obj["status"]["version"]
    wait_for_deployments_to_run(
        kube_cluster.kube_client,
        [nginx_ingress_controller_name],
        nginx_ingress_controller_name,
        timeout,
    )
    assert app_version == nginx_ingress_controller_app_chart_version
    logger.info(f"cni App CR shows installed appVersion {app_version}")


# scope "module" means this is run only once, for the first test case requesting! It might be tricky
# if you want to assert this multiple times


@pytest.fixture(scope="module")
def app_deployment(kube_cluster: Cluster) -> List[pykube.Deployment]:
    deployments = wait_for_deployments_to_run(
        kube_cluster.kube_client,
        ["dex", "dex-k8s-authenticator-customer"],
        "default",
        timeout,
    )
    return deployments

# when we start the tests on circleci, we have to wait for pods to be available, hence
# this additional delay and retries


@pytest.mark.smoke
@pytest.mark.flaky(reruns=5, reruns_delay=10)
def test_pods_available(kube_cluster: Cluster, app_deployment: List[pykube.Deployment]):
    for d in app_deployment:
        assert int(d.obj["status"]["readyReplicas"]) > 0
