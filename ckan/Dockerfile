FROM ckan/ckan-base:2.11

# Install any extensions needed by your CKAN instance
# See Dockerfile.dev for more details and examples

# Copy custom initialization scripts
COPY --chown=ckan-sys:ckan-sys docker-entrypoint.d/* /docker-entrypoint.d/

# Apply any patches needed to CKAN core or any of the built extensions (not the
# runtime mounted ones)
COPY --chown=ckan-sys:ckan-sys patches ${APP_DIR}/patches

COPY --chown=ckan:ckan-sys cert/* cert/

USER root
RUN apt-get update && apt-get install -y \
    xmlsec1 \
    && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/linux-prod-ipb/ckanext-saml2auth.git \
    && cd ckanext-saml2auth \
    && pip install -e . \
    && if [ -f requirements.txt ]; then pip install -r requirements.txt; fi \
    && if [ -f dev-requirements.txt ]; then pip install -r dev-requirements.txt; fi

ARG GITHUB_TOKEN
RUN if [ -n "$GITHUB_TOKEN" ]; then \
        git clone https://${GITHUB_TOKEN}@github.com/linux-prod-ipb/ckanext-ipb_dataverse_theme.git; \
    else \
        git clone https://github.com/linux-prod-ipb/ckanext-ipb_dataverse_theme.git; \
    fi \
    && cd ckanext-ipb_dataverse_theme \
    && pip install -e . \
    && if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

USER ckan

RUN for d in $APP_DIR/patches/*; do \
        if [ -d $d ]; then \
            for f in `ls $d/*.patch | sort -g`; do \
                cd $SRC_DIR/`basename "$d"` && echo "$0: Applying patch $f to $SRC_DIR/`basename $d`"; patch -p1 < "$f" ; \
            done ; \
        fi ; \
    done
