#!/bin/bash

# Setup ckanext-s3filestore configuration
# This script runs at CKAN container startup via /docker-entrypoint.d/
#
# MinIO yang digunakan: https://cdndataverse.ipb.ac.id  bucket: dataverse
#
# Env vars yang WAJIB di-set di .env:
#   MINIO_ACCESS_KEY  (atau CKANEXT__S3FILESTORE__AWS_ACCESS_KEY_ID)
#   MINIO_SECRET_KEY  (atau CKANEXT__S3FILESTORE__AWS_SECRET_ACCESS_KEY)

if [[ $CKAN__PLUGINS == *"s3filestore"* ]]; then
    echo "[s3filestore] Configuring ckanext-s3filestore for MinIO @ cdndataverse.ipb.ac.id ..."

    # Support dua format nama env var:
    # - MINIO_ACCESS_KEY / MINIO_SECRET_KEY (format MinIO asli)
    # - CKANEXT__S3FILESTORE__AWS_ACCESS_KEY_ID / ... (format ckanext-envvars)
    ACCESS_KEY="${CKANEXT__S3FILESTORE__AWS_ACCESS_KEY_ID:-${MINIO_ACCESS_KEY}}"
    SECRET_KEY="${CKANEXT__S3FILESTORE__AWS_SECRET_ACCESS_KEY:-${MINIO_SECRET_KEY}}"
    BUCKET="${CKANEXT__S3FILESTORE__AWS_BUCKET_NAME:-dataverse}"
    HOST="${CKANEXT__S3FILESTORE__HOST_NAME:-https://cdndataverse.ipb.ac.id}"

    # Validasi: access key dan secret key harus ada
    if [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ]; then
        echo "[s3filestore] ERROR: MINIO_ACCESS_KEY dan MINIO_SECRET_KEY harus di-set di .env!"
        echo "[s3filestore] Skipping s3filestore configuration."
        exit 0
    fi

    # Konfigurasi wajib
    ckan config-tool $CKAN_INI \
        "ckanext.s3filestore.aws_bucket_name=${BUCKET}" \
        "ckanext.s3filestore.aws_access_key_id=${ACCESS_KEY}" \
        "ckanext.s3filestore.aws_secret_access_key=${SECRET_KEY}" \
        "ckanext.s3filestore.host_name=${HOST}" \
        "ckanext.s3filestore.region_name=${CKANEXT__S3FILESTORE__REGION_NAME:-us-east-1}" \
        "ckanext.s3filestore.signature_version=${CKANEXT__S3FILESTORE__SIGNATURE_VERSION:-s3v4}" \
        "ckanext.s3filestore.addressing_style=${CKANEXT__S3FILESTORE__ADDRESSING_STYLE:-path}" \
        "ckanext.s3filestore.acl=${CKANEXT__S3FILESTORE__ACL:-public-read}" \
        "ckanext.s3filestore.check_access_on_startup=false"

    # Optional: download proxy
    if [ -n "$CKANEXT__S3FILESTORE__DOWNLOAD_PROXY" ]; then
        ckan config-tool $CKAN_INI \
            "ckanext.s3filestore.download_proxy=${CKANEXT__S3FILESTORE__DOWNLOAD_PROXY}"
    fi

    echo "[s3filestore] Done! bucket=${BUCKET} host=${HOST}"
else
    echo "[s3filestore] s3filestore not in CKAN__PLUGINS, skipping"
fi
