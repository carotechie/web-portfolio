# Guía de Configuración de Dominio Personalizado

Esta guía cubre todas las formas de conectar un dominio personalizado a tu sitio web en AWS.

Hay 3 escenarios — elige el que corresponda a tu situación:

- [Escenario A](#escenario-a--comprar-un-dominio-directamente-en-aws-route53) — No tienes dominio aún → cómpralo en Route53
- [Escenario B](#escenario-b--tienes-un-dominio-en-otro-proveedor) — Tienes un dominio en GoDaddy, Namecheap, Google Domains, etc. → mueve el DNS a Route53
- [Escenario C](#escenario-c--mantener-el-dominio-en-tu-proveedor-actual) — Quieres mantener tu dominio donde está → apunta un CNAME a CloudFront

---

## Escenario A — Comprar un dominio directamente en AWS Route53

La opción más simple. Todo queda dentro de AWS.

### Registrar el dominio

```bash
# Verificar si tu dominio está disponible
aws route53domains check-domain-availability \
  --domain-name tu-dominio.com \
  --region us-east-1 \
  --output json

# Registrarlo (esto cobra a tu cuenta de AWS)
aws route53domains register-domain \
  --domain-name tu-dominio.com \
  --duration-in-years 1 \
  --admin-contact file://contact.json \
  --registrant-contact file://contact.json \
  --tech-contact file://contact.json \
  --privacy-protect-admin-contact \
  --privacy-protect-registrant-contact \
  --privacy-protect-tech-contact \
  --region us-east-1
```

Para el archivo contact.json, créalo con tus datos:

```json
{
  "FirstName": "Tu",
  "LastName": "Nombre",
  "ContactType": "PERSON",
  "OrganizationName": "",
  "AddressLine1": "Tu Dirección",
  "City": "Tu Ciudad",
  "CountryCode": "US",
  "ZipCode": "00000",
  "PhoneNumber": "+1.5555555555",
  "Email": "tu@email.com"
}
```

O regístralo directamente en la consola de AWS:
- Ve a Route53 → Domains → Register domain
- Busca tu dominio, agrégalo al carrito, completa los datos de contacto y compra

El registro tarda 5–15 minutos. AWS crea automáticamente una zona alojada para ti.

### Obtener el ID de tu zona alojada

```bash
aws route53 list-hosted-zones --output json \
  --query "HostedZones[?Name=='tu-dominio.com.'].Id" \
  --output text
# Retorna algo como: /hostedzone/Z1234567890ABC
# Usa solo la última parte: Z1234567890ABC
```

Ahora ve a [Solicitar Certificado ACM](#solicitar-un-certificado-acm).

---

## Escenario B — Tienes un dominio en otro proveedor

Transferirás la gestión del DNS a Route53 (no el registro del dominio en sí — solo los nameservers). Es gratuito y tarda unos 5 minutos en configurarse, más hasta 48 horas para la propagación.

### Crear una zona alojada en Route53

```bash
aws route53 create-hosted-zone \
  --name tu-dominio.com \
  --caller-reference "$(date +%s)" \
  --output json
```

Anota los 4 nameservers en la salida — se ven así:
```
ns-123.awsdns-45.com
ns-678.awsdns-90.net
ns-111.awsdns-22.org
ns-999.awsdns-00.co.uk
```

O créala en la consola: Route53 → Hosted zones → Create hosted zone.

### Actualizar los nameservers en tu proveedor

Inicia sesión en tu proveedor de dominio y busca la configuración de DNS / Nameservers. Reemplaza los nameservers existentes con los 4 de Route53.

Guías por proveedor:
- GoDaddy: Mis Productos → DNS → Nameservers → Cambiar → Ingresar mis propios nameservers
- Namecheap: Lista de Dominios → Administrar → Nameservers → DNS Personalizado
- Google Domains / Squarespace: DNS → Nameservers → Personalizado
- Cloudflare: Elimina el sitio de Cloudflare, luego actualiza en tu proveedor

### Verificar la propagación

```bash
# Verificar qué nameservers responden para tu dominio
dig NS tu-dominio.com

# O usa una herramienta en línea
# https://www.whatsmydns.net/#NS/tu-dominio.com
```

Una vez que aparezcan los nameservers de Route53, el DNS está delegado. Esto puede tardar desde unos minutos hasta 48 horas según tu proveedor.

### Obtener el ID de tu zona alojada

```bash
aws route53 list-hosted-zones --output json \
  --query "HostedZones[?Name=='tu-dominio.com.'].Id" \
  --output text
```

Continúa con [Solicitar Certificado ACM](#solicitar-un-certificado-acm).

---

## Escenario C — Mantener el dominio en tu proveedor actual

No necesitas mover nada. Solo agregarás un registro CNAME apuntando a tu distribución de CloudFront.

Omite la configuración de zona alojada. Después de desplegar con Terraform (con `enable_custom_domain = false`), obtén tu dominio de CloudFront:

```bash
cd terraform
terraform output cloudfront_domain_name
# Retorna: d1234567890abc.cloudfront.net
```

Ve a la configuración DNS de tu proveedor y agrega:

| Tipo | Nombre | Valor |
|------|--------|-------|
| CNAME | `tech` (o `@` para el dominio raíz) | `d1234567890abc.cloudfront.net` |

Nota: la mayoría de los proveedores no soportan CNAME en el dominio raíz (`@`). Si necesitas el dominio raíz, usa el Escenario A o B, o usa un subdominio como `tech.tudominio.com`.

No necesitarás `route53_zone_id` en tu tfvars para este escenario. El SSL sigue funcionando via ACM — continúa con [Solicitar Certificado ACM](#solicitar-un-certificado-acm).

---

## Solicitar un Certificado ACM

Sin importar qué escenario elegiste, el certificado debe estar en `us-east-1` para CloudFront.

```bash
aws acm request-certificate \
  --domain-name tu-dominio.com \
  --validation-method DNS \
  --region us-east-1 \
  --output json
```

Obtén el ARN del certificado:

```bash
aws acm list-certificates \
  --region us-east-1 \
  --query "CertificateSummaryList[?DomainName=='tu-dominio.com'].CertificateArn" \
  --output text
```

### Validar el certificado

ACM necesita verificar que eres dueño del dominio comprobando un registro CNAME.

**Si tu dominio está en Route53 (Escenario A o B):**
Ve a la consola de ACM → tu certificado → haz clic en "Create records in Route53". Listo con un clic.

**Si tu dominio está en otro proveedor (Escenario C):**
Obtén los detalles del CNAME de validación:

```bash
aws acm describe-certificate \
  --certificate-arn TU_CERT_ARN \
  --region us-east-1 \
  --query "Certificate.DomainValidationOptions[0].ResourceRecord" \
  --output json
```

Agrega ese registro CNAME manualmente en tu proveedor.

Verifica el estado de validación:

```bash
aws acm describe-certificate \
  --certificate-arn TU_CERT_ARN \
  --region us-east-1 \
  --query "Certificate.Status" \
  --output text
# Espera hasta que retorne: ISSUED
```

---

## Actualizar terraform.tfvars

Una vez que el certificado esté emitido, actualiza tus variables:

```hcl
enable_custom_domain = true
domain_name          = "tu-dominio.com"
acm_certificate_arn  = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERT_ID"

# Solo necesario para Escenario A o B (dominio en Route53)
route53_zone_id      = "Z1234567890ABC"

# Dejar vacío para Escenario C (dominio en proveedor externo)
# route53_zone_id    = ""
```

Luego vuelve a desplegar:

```bash
./deploy-to-aws.sh
```

---

## Verificar tu dominio personalizado

```bash
# Verificar que el DNS resuelve
dig tu-dominio.com

# Probar HTTPS
curl -I https://tu-dominio.com
# Debe retornar: HTTP/2 200
```

O verifica la propagación globalmente: https://www.whatsmydns.net

---

## Solución de problemas

**Certificado atascado en "Pending validation" después de 30 min**
- Confirma que el registro CNAME de validación existe en DNS: `dig CNAME _abc123.tu-dominio.com`
- Asegúrate de que el certificado fue solicitado en `us-east-1` — los certificados en otras regiones no funcionan con CloudFront
- Si el registro está ahí, solo espera — puede tardar hasta 30 minutos

**CloudFront retorna 403 después de agregar dominio personalizado**
- Asegúrate de que `enable_custom_domain = true` y `acm_certificate_arn` están configurados en tfvars
- Vuelve a ejecutar `terraform apply`

**El dominio no resuelve después del cambio de nameservers**
- La propagación DNS puede tardar hasta 48 horas
- Verifica los nameservers actuales: `dig NS tu-dominio.com`
- Usa https://www.whatsmydns.net para verificar desde múltiples ubicaciones

**CNAME no funciona en el dominio raíz**
- Los dominios raíz (`@`) no pueden usar registros CNAME — usa un subdominio como `www` o `tech`
- O muévete a Route53 que soporta registros ALIAS en dominios raíz (Escenario A o B)
