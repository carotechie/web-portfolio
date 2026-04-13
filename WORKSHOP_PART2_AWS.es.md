# Parte 2 — Despliegue en AWS (50 min)

En esta parte desplegarás tu sitio web en AWS usando Terraform. Al finalizar estará en vivo en una URL pública.

La última sección opcional cubre la conexión de un dominio personalizado con HTTPS.

---

## Paso 1 — Configurar credenciales de AWS (5 min)

```bash
export AWS_ACCESS_KEY_ID="tu-access-key-id"
export AWS_SECRET_ACCESS_KEY="tu-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

Verifica que funcione:

```bash
aws sts get-caller-identity --output json
```

Deberías ver tu ID de cuenta y ARN de usuario.

---

## Paso 2 — Crear el bucket de estado de Terraform (10 min)

Terraform necesita un bucket S3 para almacenar su estado antes de poder crear cualquier otra cosa. Esta es una configuración de una sola vez.

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

Escribe `yes` cuando se te solicite. Esto crea el bucket `tf-state-carotechie`.

Ahora adjunta la política IAM a tu usuario de despliegue para que tenga permisos para crear todos los recursos del sitio web:

```bash
export IAM_USERNAME="tu-usuario-iam"

aws iam put-user-policy \
  --user-name $IAM_USERNAME \
  --policy-name CarolinaWebsitePolicy \
  --policy-document file://policy.json
```

Luego migra el estado del bootstrap a S3. En `terraform/bootstrap/main.tf`, comenta `backend "local" {}` y descomenta el bloque `backend "s3"`, luego:

```bash
terraform init -migrate-state
```

Escribe `yes` para migrar. Detalles completos en [terraform/bootstrap/README.md](terraform/bootstrap/README.md).

---

## Paso 3 — Configurar variables de Terraform (5 min)

```bash
cd ../..
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edita `terraform/terraform.tfvars` — como mínimo establece tu nombre de dominio como nombre del bucket S3:

```hcl
aws_region           = "us-east-1"
environment          = "production"
domain_name          = "tu-nombre-de-bucket-unico"  # se usa como nombre del bucket S3 — debe ser globalmente único
enable_custom_domain = false                          # pon true solo si tienes dominio + certificado listos
```

---

## Paso 4 — Habilitar el backend S3 en main.tf (2 min)

En `terraform/main.tf`, comenta `backend "local" {}` y descomenta el bloque `backend "s3"`:

```hcl
backend "s3" {
  bucket  = "tf-state-carotechie"
  key     = "website/terraform.tfstate"
  region  = "us-east-1"
  encrypt = true
}
```

Luego inicializa:

```bash
cd terraform
terraform init
```

---

## Paso 5 — Desplegar (15 min)

```bash
cd ..
./deploy-to-aws.sh
```

El script mostrará un plan y pedirá confirmación antes de crear cualquier cosa. Escribe `yes`.

Creará:
- Bucket S3 para los archivos de tu sitio web
- Distribución CloudFront (CDN global + HTTPS)
- Registros DNS en Route53 (si el dominio personalizado está habilitado)

El despliegue tarda 10–15 minutos. El aprovisionamiento de CloudFront es la parte más lenta.

Al final obtendrás una URL como:
```
https://d1234567890abc.cloudfront.net
```

Ábrela — tu sitio web está en vivo.

---

## Paso 6 — Verificar (3 min)

```bash
# Verificar que CloudFront está desplegado
aws cloudfront get-distribution \
  --id $(cd terraform && terraform output -raw cloudfront_distribution_id) \
  --query 'Distribution.Status' \
  --output text
# Debe retornar: Deployed

# Probar la URL
curl -I $(cd terraform && terraform output -raw website_url)
# Debe retornar: HTTP/2 200
```

---

## Punto de control

- [ ] `terraform apply` completado exitosamente
- [ ] El sitio web es accesible via URL de CloudFront
- [ ] Tu nombre y contenido aparecen correctamente
- [ ] HTTPS funciona

---

## Opcional — Dominio personalizado con HTTPS (10 min)

Solo haz esto si tienes un dominio listo. Hay 3 formas de configurarlo según dónde esté tu dominio:

- Sin dominio aún → cómpralo en Route53
- Dominio en GoDaddy, Namecheap, etc. → mueve el DNS a Route53
- Mantén el dominio en tu proveedor actual → apunta un CNAME a CloudFront

Guía paso a paso para los 3 escenarios: [WORKSHOP_CUSTOM_DOMAIN.es.md](WORKSHOP_CUSTOM_DOMAIN.es.md)

Una vez que tu certificado esté emitido y `terraform.tfvars` esté actualizado con `enable_custom_domain = true`, `acm_certificate_arn` y `route53_zone_id`, vuelve a ejecutar:

```bash
./deploy-to-aws.sh
```

---

## Actualizar tu sitio web después

Cada vez que hagas cambios, simplemente ejecuta:

```bash
./update-website.sh
```

Los archivos se sincronizan con S3 y el caché de CloudFront se limpia automáticamente. Los cambios están en vivo en 2–5 minutos.

---

## Solución de problemas

**Certificado atascado en "Pending validation"**
- Haz clic en "Create records in Route53" en la consola de ACM
- Ejecuta `dig CNAME _registro-validacion.tu-dominio.com` para confirmar que el registro existe
- Asegúrate de que el certificado fue creado en `us-east-1`

**El sitio web muestra contenido antiguo después de actualizar**
```bash
./update-website.sh
```

**Acceso denegado en S3**
```bash
cd terraform && terraform apply -auto-approve
```

**CloudFront aún desplegando**
- Espera unos minutos más y verifica con `terraform output website_url`
