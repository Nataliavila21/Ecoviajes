# EcoViajes — Planeador de viajes económicos

Proyecto escolar de sistema experto con SWI-Prolog, Flask, HTML, CSS y JavaScript.

## Estado
La interfaz y el backend están preparados. La lógica de `motor.pl` debe ser escrita por los estudiantes conforme a la restricción académica.

## Requisitos
- Python 3.10 o superior
- SWI-Prolog (`swipl` accesible desde la terminal)

## Instalación
```bash
python -m venv .venv
# Windows:
.venv\Scripts\activate
pip install -r requirements.txt
python app.py
```
Abrir http://127.0.0.1:5000

## Contrato del motor Prolog
El backend ejecuta:
`swipl -q -s motor.pl -g main -t halt -- PRESUPUESTO DIAS TRANSPORTE TIPO`

El predicado `main` escrito por el equipo debe devolver un JSON en stdout:
`{"resultados":[{"destino":"Ejemplo","costo":2500,"explicacion":"Razón inferida"}]}`

Si no hay opciones: `{"resultados":[]}`.

## Publicación
Después de implementar y probar Prolog, publicar en un servicio que permita instalar SWI-Prolog, por ejemplo mediante Docker. Verificar los costos y requisitos del proveedor antes de desplegar.

## Declaración de IA
La IA se utilizó para orientar el diseño y generar archivos de interfaz, backend y documentación inicial. Los hechos, reglas y predicados del motor lógico deben ser realizados por el equipo.

## Archivos adicionales
- `DESTINOS_PARA_INVESTIGAR.csv`: 20 destinos; costos sin inventar, por investigar desde CDMX.
- `PRUEBAS.md`: matriz de 10 casos para registrar evidencias reales.
- `Dockerfile`: contenedor con Flask y SWI-Prolog para despliegue una vez completado el motor.

## Comprobaciones
`python -m py_compile app.py` verifica la sintaxis del backend.
`node --check static/app.js` verifica la sintaxis de JavaScript si tienes Node instalado.
`docker build -t ecoviajes .` construye el contenedor si tienes Docker.

**Nota:** Sin la lógica original de `motor.pl`, las recomendaciones no funcionarán. No se ha publicado el sitio ni ejecutado casos de inferencia.
