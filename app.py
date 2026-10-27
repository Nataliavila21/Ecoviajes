from flask import Flask, render_template, request, jsonify
import subprocess
import json
import os

app = Flask(__name__)
BASE = os.path.dirname(os.path.abspath(__file__))

@app.get('/')
def inicio():
    return render_template('index.html')

@app.post('/api/planear')
def planear():
    datos = request.get_json(silent=True)
    if not isinstance(datos, dict):
        return jsonify(error='Completa los datos del formulario.'), 400
    try:
        presupuesto = int(datos.get('presupuesto', ''))
        dias = int(datos.get('dias', ''))
    except (TypeError, ValueError):
        return jsonify(error='Ingresa un presupuesto y una duración válidos.'), 400
    transporte = datos.get('transporte')
    tipo = datos.get('tipo')
    if not 100 <= presupuesto <= 100000:
        return jsonify(error='El presupuesto debe estar entre $100 y $100,000 MXN.'), 400
    if not 1 <= dias <= 30:
        return jsonify(error='La duración debe ser de 1 a 30 días.'), 400
    if transporte not in ('autobus', 'auto', 'cualquiera'):
        return jsonify(error='Selecciona un transporte válido.'), 400
    if tipo not in ('playa', 'cultura', 'naturaleza', 'pueblo', 'pueblo_magico', 'cualquiera'):
        return jsonify(error='Selecciona un tipo de destino válido.'), 400

    archivo = os.path.join(BASE, 'motor.pl')
    if not os.path.isfile(archivo):
        return jsonify(error='No se encontró el archivo motor.pl.'), 503
    comando = ['swipl', '-q', '-s', archivo, '-g', 'main', '-t', 'halt', '--',
               str(presupuesto), str(dias), transporte, tipo]
    try:
        proceso = subprocess.run(comando, capture_output=True, text=True,
                                 timeout=10, cwd=BASE, encoding='utf-8')
    except FileNotFoundError:
        return jsonify(error='No se encontró SWI-Prolog. Revisa su instalación.'), 503
    except subprocess.TimeoutExpired:
        return jsonify(error='La búsqueda tardó demasiado. Intenta de nuevo.'), 504
    if proceso.returncode != 0:
        app.logger.error('Error Prolog: %s', proceso.stderr)
        return jsonify(error='No pudimos consultar los destinos. Revisa la terminal.'), 502
    try:
        resultado = json.loads(proceso.stdout)
    except json.JSONDecodeError:
        app.logger.error('Salida no JSON de Prolog: %s', proceso.stdout)
        return jsonify(error='No se pudieron leer las recomendaciones.'), 502
    if not isinstance(resultado, dict) or not isinstance(resultado.get('resultados'), list):
        return jsonify(error='La respuesta de Prolog no tiene el formato esperado.'), 502
    return jsonify(resultado)

if __name__ == '__main__':
    app.run(debug=True)
