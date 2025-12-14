# mongo_pbm_backup

This role deploys Percona Backup for MongoDB (PBM) inside a dedicated Docker container, renders a hardened PBM configuration file, and installs a systemd timer to trigger recurring backups for the `airconcheck` MongoDB replica set.

## Requirements

- Target hosts must already have Docker Engine (with `docker compose` plugin) installed and running.
- The MongoDB replica set must be reachable from the host and credentials must exist for PBM.
- Sensitive values (MongoDB credentials, S3 keys, etc.) live in `group_vars/secrets.yml`, which the main playbook loads for every environment.

## Credential sourcing

`playbooks/site.yml` imports `group_vars/secrets.yml` before role execution, so the PBM role automatically reuses the shared `mongo_pmm_user`/`mongo_pmm_password` credentials unless you override `mongo_pbm_mongodb_user` or `mongo_pbm_mongodb_uri`. S3 access keys for PBM should also be defined once in that same secrets file; every inventory environment can then reference them without duplication. 

If you prefer dedicated credentials per environment, declare them inside `inventories/<env>/group_vars/<env>.yml` (or a Vault-encrypted secrets file) and they will override the defaults described below.

## Mandatory variables

| Variable | Purpose |
| --- | --- |
| `mongo_pbm_mongodb_uri`† | MongoDB connection string including replica set members and credentials. |
| `mongo_pbm_docker_network` | Existing Docker network that provides connectivity to MongoDB. |
| `mongo_pbm_storage_type` | Either `s3` or `filesystem`. |
| `mongo_pbm_s3_access_key`* | S3 access key (required when `mongo_pbm_storage_type == 's3'`). |
| `mongo_pbm_s3_secret_key`* | S3 secret key (required for S3). |
| `mongo_pbm_s3_region`* | S3 region. |
| `mongo_pbm_s3_bucket`* | Bucket that stores PBM artifacts. |

`*` Only needed for S3 storage. When `mongo_pbm_storage_type` is `filesystem`, ensure `mongo_pbm_filesystem_path` (defaults to `{{ mongo_pbm_backups_dir }}`) points to a persistent mount.

`†` Optional when `mongo_pmm_user`/`mongo_pmm_password` exist in `group_vars/secrets.yml`; the role will derive the URI automatically from those shared credentials and the default replica members.

## Optional variables (defaults)

See [`defaults/main.yml`](defaults/main.yml) for the full list. Common ones:

- `mongo_pbm_base_dir: /opt/airconcheck/mongo_pbm`
- `mongo_pbm_image: percona/percona-backup-mongodb:latest`
- `mongo_pbm_backup_oncalendar: daily`
- `mongo_pbm_backup_extra_args: --compression=s2`
- `mongo_pbm_backup_description_prefix: scheduled`
- `mongo_pbm_apply_config: true`

mongo_pbm_s3_bucket: "airconcheck-mongo-backups-prod"
mongo_pbm_s3_endpoint: "https://s3.example.com"
mongo_pbm_s3_prefix: "prod/"
## Environment overrides

Inventory group vars can specialize PBM without duplicating secrets. For example:

`inventories/dev/group_vars/dev.yml`

```yaml
mongo_pbm_storage_type: "filesystem"
mongo_pbm_filesystem_path: "/opt/airconcheck/mongo_pbm/backups/dev"
mongo_pbm_docker_network: "internal_db"
```

`inventories/test/group_vars/test.yml`

```yaml
mongo_pbm_storage_type: "filesystem"
mongo_pbm_filesystem_path: "/opt/airconcheck/mongo_pbm/backups/test"
mongo_pbm_docker_network: "internal_db"
```

`inventories/prod/group_vars/prod.yml`

```yaml
mongo_pbm_storage_type: "s3"
mongo_pbm_docker_network: "internal_db"
mongo_pbm_backup_oncalendar: "daily"
```

`group_vars/secrets.yml` (shared for all environments)

```yaml
mongo_pmm_user: "airconcheck-pmm"
mongo_pmm_password: "REPLACE_ME"
mongo_pbm_s3_access_key: "REPLACE_ME"
mongo_pbm_s3_secret_key: "REPLACE_ME"
mongo_pbm_s3_region: "eu-west-1"
mongo_pbm_s3_bucket: "airconcheck-mongo-backups-prod"
mongo_pbm_s3_endpoint: "https://s3.example.com"
mongo_pbm_s3_prefix: "prod/"
```

Playbook snippet:

```yaml
- name: Configure PBM backups for MongoDB (prod)
  hosts: mongo_prod_hosts
  become: true
  roles:
    - role: mongo_pbm_backup
```

## Behavior

1. Creates `/opt/airconcheck/mongo_pbm` (by default) to hold PBM config, compose file, and backup data.
2. Deploys a Docker Compose project with a long-lived PBM container ready for exec/run commands.
3. Renders `pbm-config.yaml` with either S3 or filesystem storage instructions.
4. Applies the PBM configuration inside the container (can be disabled via `mongo_pbm_apply_config`).
5. Installs a `mongo-pbm-backup.timer` systemd unit that periodically runs `pbm backup` via `docker compose run`.

Adjust the defaults to switch to cron-based scheduling or integrate with external monitoring if needed.
