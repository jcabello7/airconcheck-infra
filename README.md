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

---

## 🧑‍💻 How to Contribute

- Clone the repo and use `playbooks/debug-vars.yml` to validate your environment
- Add environment-specific overrides in `inventories/<env>/group_vars/`
- Submit clean PRs with meaningful commits
- Stick to naming conventions

Happy hacking!
