# Guía de Despliegue

Esta guía cubre todo lo necesario para ejecutar el sitio web localmente y desplegarlo en AWS — primera vez y actualizaciones posteriores.

---

## Descripción de los scripts

| Script | Propósito |
|--------|-----------|
| `./run-local.sh` | Construye e inicia el sitio web localmente via Docker en http://localhost |
| `./deploy-to-aws.sh` | Despliegue completo inicial en AWS — crea toda la infraestructura y sube los archivos |
| `./update-website.sh` | Actualizaciones posteriores — sincroniza los archivos modificados a S3 e invalida el caché de CloudFront |

---

## Ejecutar localmente

Asegúrate de que Docker Desktop esté en ejecución, luego:

```bash
./run-local.sh
```

Abre http://localhost en tu navegador.

Para detenerlo:
```bash
docker-compose down
```

---

## Despliegue en AWS — Primera vez

Sigue estos pasos en orden la primera vez.

### Paso 1 — Configurar credenciales de AWS

```bash
export AWS_ACCESS_KEY_ID="tu-access-key-id"
export AWS_SECRET_ACCESS_KEY="tu-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"

# Verificar
aws sts get-caller-identity --output json
```

### Paso 2 — Crear el bucket de estado de Terraform

El bucket de estado debe existir antes de desplegar la infraestructura principal.
Sigue todos los pasos en [`terraform/bootstrap/README.md`](terraform/bootstrap/README.md).

Esto crea el bucket S3 `tf-state-carotechie` y adjunta la política IAM a tu usuario de despliegue.

### Paso 3 — Solicitar un certificado ACM

El certificado debe estar en `us-east-1` sin importar dónde esté alojado tu sitio.

```bash
aws acm request-certificate \
  --domain-name tech.carolinaherreramonteza.com \
  --validation-method DNS \
  --region us-east-1
```

Obtén el ARN del certificado:
```bash
aws acm list-certificates --region us-east-1 --output json
```

Valídalo — ve a ACM en la consola de AWS, abre el certificado y haz clic en "Create records in Route53". El estado cambia a "Issued" en ~5 minutos.

Confirma que está emitido:
```bash
aws acm describe-certificate \
  --certificate-arn TU_CERT_ARN \
  --region us-east-1 \
  --query "Certificate.Status" \
  --output text
```

### Paso 4 — Configurar variables de Terraform

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edita `terraform/terraform.tfvars`:

```hcl
aws_region           = "us-east-1"
environment          = "production"
domain_name          = "tech.carolinaherreramonteza.com"
enable_custom_domain = true
acm_certificate_arn  = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERT_ID"
route53_zone_id      = "TU_ZONE_ID_EXISTENTE"
```

Encuentra tu ID de zona alojada:
```bash
aws route53 list-hosted-zones \
  --query "HostedZones[?Name=='carolinaherreramonteza.com.'].Id" \
  --output text
```

### Paso 5 — Habilitar el backend S3 en main.tf

En `terraform/main.tf`, descomenta el bloque backend:

```hcl
backend "s3" {
  bucket  = "tf-state-carotechie"
  key     = "website/terraform.tfstate"
  region  = "us-east-1"
  encrypt = true
}
```

Luego inicializa Terraform para conectarse al backend remoto:

```bash
cd terraform
terraform init
```

### Paso 6 — Desplegar

```bash
./deploy-to-aws.sh
```

El script:
1. Valida los prerequisitos (AWS CLI, Terraform, credenciales)
2. Ejecuta `terraform plan` y muestra lo que se creará
3. Pide confirmación antes de aplicar
4. Crea todos los recursos de AWS (S3, CloudFront, registros Route53)
5. Sube los archivos del sitio web a S3
6. Invalida el caché de CloudFront
7. Imprime la URL en vivo

El despliegue tarda 10–15 minutos (el aprovisionamiento de CloudFront es la parte más lenta).

---

## Actualizaciones posteriores

Una vez que la infraestructura existe, simplemente ejecuta:

```bash
./update-website.sh
```

Esto sincroniza solo los archivos del sitio web (HTML, CSS, JS, imágenes) a S3 y limpia el caché de CloudFront. Los cambios están en vivo en 2–5 minutos.

---

## Solución de problemas

**Certificado ACM atascado en "Pending validation"**
- Ve a la consola de ACM → tu certificado → "Create records in Route53"
- Verifica que el registro CNAME existe: `dig CNAME _abc123.tech.carolinaherreramonteza.com`
- Asegúrate de que el certificado fue creado en `us-east-1`

**El sitio web muestra contenido antiguo**
```bash
./update-website.sh
```

**Acceso denegado en S3**
```bash
cd terraform
terraform apply -auto-approve
```

**Estado de Terraform no encontrado al ejecutar update-website.sh**
- La infraestructura aún no ha sido desplegada — ejecuta `./deploy-to-aws.sh` primero

**Distribución de CloudFront aún desplegando**
```bash
aws cloudfront get-distribution \
  --id $(cd terraform && terraform output -raw cloudfront_distribution_id) \
  --query 'Distribution.Status' \
  --output text
```
Espera hasta que retorne `Deployed`.

---

## Estimación de costos

| Servicio | Capa gratuita | Después de la capa gratuita |
|----------|---------------|------------------------------|
| S3 | 5GB / 20k solicitudes | ~$0.023/GB |
| CloudFront | 1TB transferencia/mes | ~$0.085/GB |
| Route53 | — | $0.50/mes por zona |
| ACM | Gratis | Gratis |

Costo esperado para un portafolio personal: ~$0.50–2/mes.
