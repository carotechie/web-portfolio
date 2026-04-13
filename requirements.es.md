# Requisitos

Todo lo que necesitas para ejecutar este sitio web localmente y desplegarlo en AWS.

---

## Desarrollo local

| Herramienta | Versión | Instalación |
|-------------|---------|-------------|
| Docker Desktop | Última | https://www.docker.com/products/docker-desktop |
| Git | Última | https://git-scm.com/downloads |
| Kiro IDE | Última | https://kiro.dev |

### Ejecutar localmente

```bash
./run-local.sh
```

Sitio web disponible en http://localhost

---

## Despliegue en AWS

| Herramienta | Versión | Instalación |
|-------------|---------|-------------|
| Terraform | >= 1.0 | https://developer.hashicorp.com/terraform/install |
| AWS CLI | >= 2.0 | https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html |

### Configuración inicial

1. Sigue `terraform/bootstrap/README.md` para crear el bucket de estado y adjuntar las políticas IAM
2. Sigue `terraform/README.md` para desplegar la infraestructura del sitio web

---

## Cuenta de AWS

- Se requiere una cuenta de AWS — https://aws.amazon.com/free
- Crea un usuario IAM dedicado (no uses el usuario root) — consulta `terraform/bootstrap/policy.json` para los permisos necesarios
- Dominio registrado y zona alojada en Route53
- Certificado ACM solicitado en la región `us-east-1`
