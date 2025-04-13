# AirconCheck Infra — Guía de despliegue y configuración

Este repositorio contiene la configuración de infraestructura de AirconCheck basada en Ansible.

---

## 🌐 Estructura de Inventario

Cada entorno (`dev`, `test`, `prod`) tiene su propio inventario dentro de `inventories/`, con su propio archivo `hosts` y variables `group_vars/`.

---

## 🚀 Playbooks

### ▶️ site.yml

Playbook principal. Despliega servicios, usuarios, Docker, SWAG, etc.

```bash
ansible-playbook playbooks/site.yml -i inventories/test/
ansible-playbook playbooks/site.yml -i inventories/dev/
ansible-playbook playbooks/site.yml -i inventories/prod/
```

### 🛠️ debug-vars.yml

Muestra las variables activas para un host.

```bash
ansible-playbook playbooks/debug-vars.yml -i inventories/test/
```

---

## 📦 Contenedores desplegados actualmente

| Servicio         | Imagen                          | Puertos           | Descripción                    |
|------------------|----------------------------------|--------------------|--------------------------------|
| angular-ssr      | node:20 + build SSR              | 4000 (interno)     | Frontend Angular SSR           |
| portainer        | portainer/portainer-ce:2.27.1    | 9000               | UI para gestión Docker         |
| swag-external    | linuxserver/swag:3.3.0           | 443                | Proxy público (Let's Encrypt)  |
| swag-internal    | linuxserver/swag:3.3.0           | 8443               | Proxy para servicios internos  |
| mongodb          | mongo:7                          | 27017              | Base de datos principal        |

---

## 🌍 URLs por entorno

| Entorno  | URL                                        | Servicio           |
|----------|---------------------------------------------|--------------------|
| prod     | https://airconcheck.com                   | Angular SSR        |
| test     | https://test.airconcheck.com              | Angular SSR (test) |
| prod     | https://portainer.airconcheck.com:8443    | Portainer interno  |
| test     | https://portainer.test.airconcheck.com:8443 | Portainer (test)  |

---

## 🔐 Gestión de secretos

Las variables sensibles estan almacenadas en `group_vars/secrets.yml`, el cual es ignorado por Git..

- Existe una plantilla en (`group_vars/secrets.yml.example`) .
- Copia y rellena el fichero con tus propios valores anted de ejecutar ningún playbook:

```bash
cp group_vars/secrets.yml.example group_vars/secrets.yml
vim group_vars/secrets.yml

---

## 🔧 Esquema de red Docker

![Esquema de red](docs/docker-network.png)
[proxy]
 ├─ angular-ssr (4000)
 └─ swag-external (443)
     ↑ endpoint público

[internal_db]
 ├─ angular-ssr
 └─ mongodb (27017)

[management]
 ├─ portainer (9000)
 └─ swag-internal (8443)
     ↑ endpoint privado

---

## 🧑‍💻 Cómo contribuir

- Clona el repositorio y ejecuta `playbooks/debug-vars.yml` para validar el entorno
- Define variables específicas por entorno en `inventories/<entorno>/group_vars/`
- Haz PRs claros, limpios y con buen historial de commits

¡Feliz automatización!
