FROM gsoci.azurecr.io/giantswarm/dex:54bd75b0b4c24298d3264237f9dd7cdd82646eaa

ENV DEX_FRONTEND_DIR=/srv/dex/web

COPY --chown=root:root web /srv/dex/web
