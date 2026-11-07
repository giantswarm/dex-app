FROM gsoci.azurecr.io/giantswarm/dex/dex:2.46.1-gs.3

ENV DEX_FRONTEND_DIR=/srv/dex/web

COPY --chown=root:root web /srv/dex/web
