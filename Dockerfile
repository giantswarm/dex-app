FROM gsoci.azurecr.io/giantswarm/dex:v2.46.0

ENV DEX_FRONTEND_DIR=/srv/dex/web

COPY --chown=root:root web /srv/dex/web
