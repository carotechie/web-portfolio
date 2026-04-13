# Parte 1 — Construye Tu Sitio Web Localmente (40 min)

En esta parte clonarás el repositorio, ejecutarás el sitio web en tu máquina y usarás Kiro para reemplazar todo el contenido con tus propios datos.

---

## Paso 1 — Clona el repositorio (2 min)

```bash
git clone https://github.com/carotechie/web-portfolio.git
cd web-portfolio
```

Abre la carpeta en Kiro IDE.

---

## Paso 2 — Ejecútalo localmente (5 min)

Asegúrate de que Docker Desktop esté en ejecución, luego:

```bash
./run-local.sh
```

Abre http://localhost — deberías ver el sitio web de Carolina. Este es tu punto de partida.

---

## Paso 3 — Personaliza con Kiro (30 min)

Abre el chat de Kiro y usa el prompt de abajo. Completa tus propios datos antes de enviarlo.

```
Quiero personalizar este sitio web de portafolio con mis propios datos.

Información personal:
- Nombre: [Tu Nombre Completo]
- Título: [Tu Cargo, ej. "Ingeniera Backend" o "Científica de Datos"]
- Años de experiencia: [X]
- Biografía: [2-3 oraciones sobre ti y lo que haces]
- LinkedIn: [tu URL de LinkedIn]
- GitHub: [tu URL de GitHub]
- Blog: [tu URL de blog, o escribe "ninguno"]
- Instagram / X / YouTube: [tus usuarios, o escribe "ninguno" para los que no uses]

Experiencia (lista cada rol):
- [Rango de años] | [Cargo] | [Empresa]
  Descripción: [lo que hiciste en 1-2 oraciones]
  Stack tecnológico: [herramientas y tecnologías separadas por comas]

Habilidades (lista tus principales áreas y herramientas):
- [Categoría]: [herramienta1, herramienta2, herramienta3]
- [Categoría]: [herramienta1, herramienta2, herramienta3]

Charlas o presentaciones:
[Pega links de YouTube si tienes, o escribe "ninguno"]

Mentoría:
[Describe cualquier trabajo de mentoría que hagas, o escribe "ninguno"]

Tema de color:
- Color principal: [ej. verde azulado, naranja, azul — o un código hex como #0ea5e9]

Dominio:
- URL del sitio web: [tu dominio o subdominio, ej. tech.tunombre.com]

Por favor:
1. Actualiza index.html con toda mi información
2. Actualiza styles.css para usar mi color elegido como tema principal
3. Actualiza el título de la página y la meta descripción
4. Actualiza terraform/terraform.tfvars con mi nombre de dominio
5. Mantén la estructura bilingüe EN/ES pero actualiza todo el contenido con mis datos
```

Después de que Kiro aplique los cambios, recarga http://localhost para ver tu versión.

---

## Paso 4 — Ajustes finales (3 min)

¿No estás conforme con algo? Usa estos prompts de seguimiento en Kiro:

**Cambiar un color:**
```
Cambia el color principal a #TU_CODIGO_HEX y actualiza todas las referencias en styles.css
```

**Actualizar una sección:**
```
Actualiza la sección de mentoría en index.html para que diga: [tu texto]
```

**Eliminar una sección que no necesitas:**
```
Elimina la sección de Charlas de index.html y el enlace de navegación correspondiente
```

**Agregar una sección:**
```
Agrega una sección de Proyectos después de Experiencia con estos proyectos: [listarlos]
```

---

## Punto de control

Antes de pasar a la Parte 2, asegúrate de que:

- [ ] El sitio web funciona en http://localhost
- [ ] Tu nombre y título aparecen en la sección principal
- [ ] Tu experiencia y habilidades son correctas
- [ ] Los colores se ven como quieres
- [ ] No hay imágenes rotas ni problemas de diseño

---

Siguiente: [Parte 2 — Despliegue en AWS](WORKSHOP_PART2_AWS.es.md)
