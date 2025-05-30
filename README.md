# AirconCheck Infra — Deployment & Configuration Guide

This repository contains the Ansible-based infrastructure configuration for the AirconCheck project.

---

## 🌐 Inventory Structure

Each environment (`dev`, `test`, `prod`) has its own isolated inventory under `inventories/`, each with its own `hosts` and `group_vars/` structure. This ensures clean separation and security.

---

## 🚀 Playbooks

### ▶️ site.yml

Main playbook. Deploys all services and config (users, docker, SWAG, etc.)

```bash
ansible-playbook playbooks/site.yml -i inventories/test/
ansible-playbook playbooks/site.yml -i inventories/dev/
ansible-playbook playbooks/site.yml -i inventories/prod/
```

### 🛠️ debug-vars.yml

Prints key variable values for a host.

```bash
ansible-playbook playbooks/debug-vars.yml -i inventories/test/
```

---

## 📦 Currently Deployed Containers

| Service         | Image                           | Ports             | Description                     |
|------------------|----------------------------------|--------------------|---------------------------------|
| angular-ssr      | node:20 + build SSR             | 4000 (internal)    | Frontend Angular SSR            |
| portainer        | portainer/portainer-ce:2.27.1   | 9000               | Docker UI                       |
| swag-external    | linuxserver/swag:3.3.0          | 443                | Public-facing reverse proxy     |
| swag-internal    | linuxserver/swag:3.3.0          | 8443               | Internal services via VPN/CF    |
| mongodb          | mongo:7                         | 27017              | Primary database                |

---

## 🌍 URLs per Environment

| Environment | URL                                      | Service           |
|-------------|-------------------------------------------|--------------------|
| prod        | https://airconcheck.com                  | Angular SSR        |
| test        | https://test.airconcheck.com             | Angular SSR (test) |
| prod        | https://portainer.airconcheck.com:8443   | Portainer (internal) |
| test        | https://portainer.test.airconcheck.com:8443 | Portainer (internal test) |

---

## 🔐 Secrets Management

Sensitive variables are stored in `group_vars/secrets.yml`, which is ignored by Git.

- A template file (`group_vars/secrets.yml.example`) is provided.
- Copy and fill with your own values before running Ansible playbooks:

```bash
cp group_vars/secrets.yml.example group_vars/secrets.yml
vim group_vars/secrets.yml

---

## 🔧 Network Overview

![Network Diagram](docs/docker-network.png)
[proxy]
 ├─ angular-ssr (4000)
 └─ swag-external (443)
     ↑ public endpoint

[internal_db]
 ├─ angular-ssr
 └─ mongodb (27017)

[management]
 ├─ portainer (9000)
 └─ swag-internal (8443)
     ↑ private endpoint
     
---

## 📦 Optional Code Deployment for Frontend and Backend

To simplify development workflows, AirconCheck supports optional automatic copying of pre-built frontend (Angular SSR) and backend (Node.js) code to the target server.

You can control this behavior per environment by toggling the following variables in your inventory (e.g., `inventories/test/group_vars/test.yml`):

```yaml
# Copy frontend Angular SSR build to the target server
angular_ssr_copy_build: true

# Copy backend Node.js code to the target server
backend_copy_build: true
```

### 🧠 How it works

- When `angular_ssr_copy_build` is `true`, Ansible will copy the contents of `dist/` (Angular SSR build) to:
  ```
  /opt/airconcheck/angular-ssr/
  ```

- When `backend_copy_build` is `true`, Ansible will copy the contents of your local `backend/` folder to:
  ```
  /opt/airconcheck/backend/
  ```

- If either variable is not defined or set to `false`, the copy step is skipped — useful for environments like production where builds are done elsewhere.

Ensure the source folders exist locally on the Ansible controller:
- `dist/` (Angular SSR)
- `backend/` (Node.js)

This allows easy separation of environments and safe deployment workflows.

---

## 🧑‍💻 How to Contribute

- Clone the repo and use `playbooks/debug-vars.yml` to validate your environment
- Add environment-specific overrides in `inventories/<env>/group_vars/`
- Submit clean PRs with meaningful commits
- Stick to naming conventions

Happy hacking!

---

## 🚀 Deployed Containers

| Container            | Ports                  | Networks           | Notes                                             |
|---------------------|------------------------|--------------------|---------------------------------------------------|
| portainer           | 9000 (internal only)   | management         | Web UI for Docker                                 |
| swag-external       | 443, 80                | proxy              | External reverse proxy with Let's Encrypt        |
| swag-internal       | 8443                   | management         | Internal reverse proxy (VPN-only access)         |
| angular-ssr         | 4000                   | proxy, internal_db | Angular frontend (SSR) served via SWAG           |
| airconcheck_backend | 3000 (only in test)    | proxy, internal_db | Node.js Express backend API                      |
| airconcheck_mongodb | —                      | internal_db        | MongoDB database                                  |

## 🌍 URLs per Environment

| Environment | Frontend URL                        | Backend URL                          |
|-------------|-------------------------------------|--------------------------------------|
| Test        | https://test.airconcheck.com        | https://api.test.airconcheck.com:8443 + `localhost:3000` |
| Production  | https://airconcheck.com             | *Not exposed*                        |

---

## 🚀 Deployed Containers: Backend

The backend is a Node.js Express service used to serve the main API consumed by the Angular frontend.

| Container         | Ports       | Networks                | Notes                                 |
|------------------|-------------|--------------------------|---------------------------------------|
| airconcheck_backend | 3000 (only in test) | proxy, internal_db      | Built from `/opt/airconcheck/backend` |

---

## 🌍 URLs per Environment

| Environment | URL                              | Notes                       |
|-------------|----------------------------------|-----------------------------|
| Test        | https://api.test.airconcheck.com:8443 | Routed via swag-internal   |
| Production  | *Not exposed*                    | Backend only used internally |

In the test environment, the backend is also accessible via port `3000` on the host (`localhost:3000`) for debugging if `expose_backend_port: true` is set.

---

## 🔐 Secrets Management

For backend access to MongoDB, ensure the `.env` file at `/opt/airconcheck/backend/.env` includes:

```env
MONGO_URL=mongodb://<user>:<pass>@mongodb:27017
```

This can be templated from Ansible using `backend.env.j2` and injected per environment.

---

## 🔗 Docker Network Diagram (including backend)

- `backend` is connected to:
  - `proxy`: for access from swag-internal
  - `internal_db`: to communicate with `mongodb`