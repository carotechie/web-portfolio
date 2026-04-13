# Crea Tu Propio Sitio Web de Portafolio — Taller

> 🇬🇧 Prefer to read this in English? → [README.md](README.md)

¡Bienvenida/o! Este es un taller práctico de 2 partes donde construirás y desplegarás tu propio sitio web de portafolio personal, usando este sitio como plantilla.

Al finalizar tendrás un sitio web en vivo en AWS con tu propio currículum, habilidades y experiencia — personalizado para que se vea como el tuyo.

---

## Antes del taller

Instala todo lo que se indica en [requirements.es.md](requirements.es.md) antes de llegar. El taller no tendrá tiempo para instalaciones.

---

## Partes del taller

### Parte 1 — Construye tu sitio web localmente (40 min)
[WORKSHOP_PART1_LOCAL.es.md](WORKSHOP_PART1_LOCAL.es.md)

Clona el repositorio, ejecútalo localmente y usa Kiro para personalizarlo con tus propios datos — nombre, experiencia, habilidades, colores y más.

### Parte 2 — Despliega en AWS (50 min)
[WORKSHOP_PART2_AWS.es.md](WORKSHOP_PART2_AWS.es.md)

Despliega tu sitio web en AWS usando Terraform. Cubre la creación del bucket de estado, el despliegue de infraestructura, la subida de archivos y opcionalmente la conexión de un dominio personalizado con HTTPS.

- [Guía de Dominio Personalizado](WORKSHOP_CUSTOM_DOMAIN.es.md) — compra un dominio en AWS, muévelo desde otro proveedor, o mantenlo donde está

---

## Documentación de referencia

- [Guía de Despliegue](DEPLOYMENT_GUIDE.es.md) — referencia completa para el primer despliegue y actualizaciones
- [README de Terraform](terraform/README.md) — detalles de infraestructura y permisos IAM
- [README de Bootstrap](terraform/bootstrap/README.md) — configuración del bucket de estado

---

## Stack tecnológico

- HTML5, CSS3, Vanilla JavaScript
- Nginx + Docker
- AWS S3 + CloudFront + Route53 + ACM
- Terraform

## Licencia

© 2026 Carolina Herrera Monteza. Todos los derechos reservados.
