FROM quay.io/giantswarm/dex:4a81bce18d5dcac35489cd95ebc36331479bbeb6

ENV DEX_FRONTEND_DIR=/srv/dex/web

COPY --chown=root:root web /srv/dex/web
