#!/bin/sh

DATS_TAG=${DATS_TAG:-"0.2.1"}

# Please Note
# This script tries to speed up python tests execution by using pipenv cache and reusing virtualenvs.
# To make this work on CI systems, you have to ensure that $PIPENV_CACHE_DIR and $VENVS_DIR
# listed below are persisted between CI system runs.

# don't override variables below
ATS_DIR="/ats"
PIPENV_CACHE_DIR=".cache/pipenv"
VENVS_DIR=".local/share/virtualenvs"

docker run -it --rm \
  -e USE_UID="$(id -u "${USER}")" \
  -e USE_GID="$(id -g "${USER}")" \
  -e DOCKER_GID="$(getent group docker | cut -d: -f3)" \
  -e PIPENV_CACHE_DIR="${ATS_DIR}/${PIPENV_CACHE_DIR}" \
  -e VENVS_DIR="${ATS_DIR}/${VENVS_DIR}" \
  -v "$(pwd):${ATS_DIR}/workdir/" \
  -v "${HOME}/${PIPENV_CACHE_DIR}:${ATS_DIR}/${PIPENV_CACHE_DIR}" \
  -v "${HOME}/${VENVS_DIR}:${ATS_DIR}/${VENVS_DIR}" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --network host \
  "quay.io/giantswarm/app-test-suite:${DATS_TAG}" "$@"
