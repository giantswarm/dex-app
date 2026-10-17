import logging
from contextlib import contextmanager
from pathlib import Path
from typing import Dict, List

import pykube
from pykube.objects import Deployment
import pytest
from pytest_helm_charts.fixtures import Cluster
from pytest_helm_charts.utils import (
    wait_for_objects_condition,
)

logger = logging.getLogger(__name__)

namespace_name = "default"

timeout: int = 180


@pytest.mark.smoke
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
def test_cluster_info(
    kube_cluster: Cluster, cluster_type: str, test_extra_info: Dict[str, str]
) -> None:
    """Example shows how you can access additional information about the cluster the tests are running on"""
    logger.info(f"Running on cluster type {cluster_type}")
    key = "external_cluster_type"
    if key in test_extra_info:
        logger.info(f"{key} is {test_extra_info[key]}")
    assert kube_cluster.kube_client is not None
    assert cluster_type != ""


# scope "module" means this is run only once, for the first test case requesting! It might be tricky
# if you want to assert this multiple times
@pytest.fixture(scope="module")
def app_deployment(kube_cluster: Cluster) -> List[pykube.Deployment]:
    if kube_cluster.kube_client is None:
        raise RuntimeError("kube_client is not defined")
    deployments = wait_for_objects_condition(
        kube_cluster.kube_client,
        Deployment,
        ["dex"],
        "default",
        # every replica Ready, not just the first: the budget test counts them
        lambda d: int(d.obj["status"].get("readyReplicas", 0)) >= int(d.obj["spec"].get("replicas", 1)),
        timeout,
        False,
    )
    return deployments


# when we start the tests on circleci, we have to wait for pods to be available, hence
# this additional delay and retries
@pytest.mark.smoke
@pytest.mark.upgrade
@pytest.mark.flaky(reruns=1, reruns_delay=15)
def test_pods_available(kube_cluster: Cluster, app_deployment: List[pykube.Deployment]):
    for d in app_deployment:
        assert int(d.obj["status"].get("readyReplicas", 0)) > 0


class PodDisruptionBudget(pykube.objects.NamespacedAPIObject):
    version = "policy/v1"
    endpoint = "poddisruptionbudgets"
    kind = "PodDisruptionBudget"


# The budget must select the dex pods (its selector carries no label that
# changes with a release) and keep one available: with the default two
# replicas a drain evicts one pod while the other serves, and waits for the
# replacement to be Ready before it may evict the second.
@pytest.mark.smoke
@pytest.mark.flaky(reruns=1, reruns_delay=15)
def test_pdb_keeps_one_available(kube_cluster: Cluster, app_deployment: List[pykube.Deployment]):
    ready = sum(int(d.obj["status"].get("readyReplicas", 0)) for d in app_deployment)
    assert ready >= 2, f"dex runs {ready} ready replicas, the default is 2"
    pdb = PodDisruptionBudget.objects(kube_cluster.kube_client).filter(namespace=namespace_name).get(name="dex")
    assert pdb.obj["spec"].get("minAvailable") == 1
    assert "maxUnavailable" not in pdb.obj["spec"]
    status = pdb.obj.get("status", {})
    assert status.get("expectedPods") == ready, f"the budget selects {status.get('expectedPods')} pods, dex runs {ready}"
    assert status.get("disruptionsAllowed", 0) == ready - 1
