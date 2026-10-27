const formulario = document.getElementById('formulario');
const resultados = document.getElementById('resultados');
const nombres = {acapulco:'Acapulco',cancun:'Cancún',puerto_vallarta:'Puerto Vallarta',mazatlan:'Mazatlán',veracruz:'Veracruz',oaxaca:'Oaxaca',guanajuato:'Guanajuato',puebla:'Puebla',morelia:'Morelia',guadalajara:'Guadalajara',taxco:'Taxco',tepoztlan:'Tepoztlán',valle_de_bravo:'Valle de Bravo',bernal:'Bernal',san_miguel_de_allende:'San Miguel de Allende',huasca_de_ocampo:'Huasca de Ocampo',mineral_del_chico:'Mineral del Chico',tolantongo:'Tolantongo',la_marquesa:'La Marquesa',nevado_de_toluca:'Nevado de Toluca'};
const nombre = valor => nombres[valor] || String(valor).replaceAll('_',' ');
const moneda = valor => new Intl.NumberFormat('es-MX',{style:'currency',currency:'MXN',maximumFractionDigits:0}).format(valor);
function elemento(etiqueta, texto, clase) {
  const nodo = document.createElement(etiqueta);
  nodo.textContent = texto;
  if (clase) nodo.className = clase;
  return nodo;
}
formulario.addEventListener('submit', async (evento) => {
  evento.preventDefault();
  const datos = Object.fromEntries(new FormData(formulario).entries());
  resultados.replaceChildren(elemento('p','Buscando destinos...'));
  const boton = formulario.querySelector('button');
  boton.disabled = true;
  try {
    const respuesta = await fetch('/api/planear', {method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(datos)});
    const salida = await respuesta.json();
    if (!respuesta.ok) throw new Error(salida.error || 'No se pudo consultar el sistema.');
    resultados.replaceChildren();
    if (salida.resultados.length) {
      resultados.append(elemento('h2',`${salida.resultados.length} destinos dentro de tu presupuesto`));
      const lista = elemento('div','','tarjetas');
      salida.resultados.sort((a,b)=>a.costo-b.costo).forEach(viaje => {
        const tarjeta = elemento('article','','tarjeta');
        tarjeta.append(elemento('h3',nombre(viaje.destino)),elemento('p',`${nombre(viaje.estado)} · ${nombre(viaje.tipo)}`),elemento('strong',moneda(viaje.costo)),elemento('p',viaje.explicacion));
        lista.append(tarjeta);
      });
      resultados.append(lista);
    } else if (salida.alternativa) {
      const alternativa = salida.alternativa;
      resultados.append(elemento('h2','No encontramos destinos dentro de tu presupuesto'),elemento('p',`Como alternativa, te recomendamos ${nombre(alternativa.destino)}. Su costo estimado es ${moneda(alternativa.costo)} y te faltarían ${moneda(alternativa.faltante)}.`));
    } else {
      resultados.append(elemento('h2','Sin recomendaciones disponibles'),elemento('p','Prueba con otra categoría, transporte o duración.'));
    }
  } catch (error) {
    resultados.replaceChildren(elemento('p',error.message,'error'));
  } finally {
    boton.disabled = false;
  }
});
