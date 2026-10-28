FROM gsoci.azurecr.io/giantswarm/dex:v2.43.3

ENV DEX_FRONTEND_DIR=/srv/dex/web

COPY --chown=root:root web /srv/dex/web
