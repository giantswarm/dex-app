FROM quay.io/giantswarm/dex:423dfdceae334a6794c84f0efdd995b18bc1798b

ENV DEX_FRONTEND_DIR=/srv/dex/web

COPY --chown=root:root web /srv/dex/web
