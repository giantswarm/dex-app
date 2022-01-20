from typing import cast

import pykube
import pytest
from pytest_helm_charts.api.deployment import wait_for_deployments_to_run
from pytest_helm_charts.fixtures import Cluster


@pytest.mark.smoke
def test_we_have_environment(kube_cluster: Cluster) -> None:
    assert kube_cluster.kube_client is not None
    assert len(pykube.Node.objects(kube_cluster.kube_client)) >= 1


@pytest.mark.functional
@pytest.mark.upgrade
def test_hello_working(kube_cluster: Cluster) -> None:
    wait_for_deployments_to_run(kube_cluster.kube_client, [
                                "dex-app"], "default", 60)
    srv = cast(
        pykube.Service, pykube.Service.objects(
            kube_cluster.kube_client).get_or_none(name="dex")
    )
    if srv is None:
        raise ValueError(
            "'dex service not found in the 'default' namespace")
    page_res = srv.proxy_http_get("/")
    assert page_res.ok
