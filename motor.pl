
% Contrato de integración esperado:
% swipl -q -s motor.pl -g main -t halt -- 3000 3 autobus cultura
%
% {"resultados":[{"destino":"Ejemplo","costo":2500,"explicacion":"Motivo"}]}
%
% Si no hay coincidencias, escribir: {"resultados":[]}
% Los mensajes de depuración deben ir a stderr, no a stdout.

% ==========================================
% ECOVIAJES - PLANEADOR DE VIAJES ECONOMICOS
% Sistema experto desarrollado en Prolog
% ==========================================

:- use_module(library(http/json)).
:- use_module(library(lists)).

% 1. BASE DE CONOCIMIENTOS
% destino(Nombre, Estado, Tipo).

% Playas
destino(acapulco, guerrero, playa).
destino(cancun, quintana_roo, playa).
destino(puerto_vallarta, jalisco, playa).
destino(mazatlan, sinaloa, playa).
destino(veracruz, veracruz, playa).

% Destinos culturales
destino(oaxaca, oaxaca, cultura).
destino(guanajuato, guanajuato, cultura).
destino(puebla, puebla, cultura).
destino(morelia, michoacan, cultura).
destino(guadalajara, jalisco, cultura).

% Pueblos magicos
destino(taxco, guerrero, pueblo_magico).
destino(tepoztlan, morelos, pueblo_magico).
destino(valle_de_bravo, estado_de_mexico, pueblo_magico).
destino(bernal, queretaro, pueblo_magico).
destino(san_miguel_de_allende, guanajuato, pueblo_magico).

% Naturaleza
destino(huasca_de_ocampo, hidalgo, naturaleza).
destino(mineral_del_chico, hidalgo, naturaleza).
destino(tolantongo, hidalgo, naturaleza).
destino(la_marquesa, estado_de_mexico, naturaleza).
destino(nevado_de_toluca, estado_de_mexico, naturaleza).

% 2. COSTOS ESTIMADOS
% transporte(Destino, Autobus, Auto).
% Los costos son de ida y vuelta.

transporte(acapulco, 1200, 1800).
transporte(cancun, 3500, 6500).
transporte(puerto_vallarta, 2400, 3500).
transporte(mazatlan, 2200, 3300).
transporte(veracruz, 1000, 1700).

transporte(oaxaca, 1100, 1800).
transporte(guanajuato, 900, 1500).
transporte(puebla, 400, 800).
transporte(morelia, 800, 1300).
transporte(guadalajara, 1300, 2200).

transporte(taxco, 500, 900).
transporte(tepoztlan, 350, 650).
transporte(valle_de_bravo, 450, 750).
transporte(bernal, 700, 1100).
transporte(san_miguel_de_allende, 900, 1500).

transporte(huasca_de_ocampo, 500, 850).
transporte(mineral_del_chico, 500, 850).
transporte(tolantongo, 800, 1300).
transporte(la_marquesa, 200, 400).
transporte(nevado_de_toluca, 400, 700).

% 3. HOSPEDAJE Y COMIDA
% gasto(Destino, HospedajePorNoche, ComidaPorDia).

gasto(acapulco, 500, 250).
gasto(cancun, 850, 400).
gasto(puerto_vallarta, 650, 300).
gasto(mazatlan, 550, 280).
gasto(veracruz, 450, 230).

gasto(oaxaca, 450, 250).
gasto(guanajuato, 500, 250).
gasto(puebla, 400, 220).
gasto(morelia, 400, 230).
gasto(guadalajara, 500, 270).

gasto(taxco, 400, 220).
gasto(tepoztlan, 450, 230).
gasto(valle_de_bravo, 550, 280).
gasto(bernal, 400, 220).
gasto(san_miguel_de_allende, 650, 300).

gasto(huasca_de_ocampo, 400, 220).
gasto(mineral_del_chico, 400, 220).
gasto(tolantongo, 450, 250).
gasto(la_marquesa, 350, 200).
gasto(nevado_de_toluca, 350, 220).

% ==========================================
% 4. REGLAS DEL SISTEMA EXPERTO
% ==========================================

% Calcular transporte elegido

costo_transporte(Destino, autobus, Costo) :-
    transporte(Destino, Costo, _).

costo_transporte(Destino, auto, Costo) :-
    transporte(Destino, _, Costo).

% Si no importa el transporte, elegir el mas barato.
costo_transporte(Destino, cualquiera, Costo) :-
    transporte(Destino, Autobus, Auto),
    Costo is min(Autobus, Auto).

% Calcular costo total
% Duracion = dias del viaje
% Noches = dias menos uno

costo_total(Destino, Dias, Medio, Total) :-
    Dias >= 1,
    costo_transporte(Destino, Medio, Transporte),
    gasto(Destino, Hospedaje, Comida),
    Noches is Dias - 1,
    Total is Transporte + Hospedaje * Noches
                     + Comida * Dias.

% Aceptar cualquier tipo de destino

tipo_valido(_, cualquiera).

tipo_valido(Tipo, Tipo) :-
    Tipo \= cualquiera.

% Recomendar viajes que no excedan presupuesto

recomendar(Presupuesto, Dias, Medio, Tipo,
           Destino, Costo) :-
    destino(Destino, _, Categoria),
    tipo_valido(Categoria, Tipo),
    costo_total(Destino, Dias, Medio, Costo),
    Costo =< Presupuesto.

% Calcular dinero restante

dinero_restante(Presupuesto, Costo, Restante) :-
    Restante is Presupuesto - Costo.

% Clasificar el viaje segun el dinero restante

clasificacion(Presupuesto, Costo, economico) :-
    Costo =< Presupuesto * 0.7.

clasificacion(Presupuesto, Costo, ajustado) :-
    Costo > Presupuesto * 0.7,
    Costo =< Presupuesto.

% ==========================================
% 5. CONEXION CON PYTHON
% ==========================================

% Interpretar las opciones del formulario

normalizar_transporte(autobus, autobus).
normalizar_transporte(auto, auto).
normalizar_transporte(cualquiera, cualquiera).

normalizar_tipo(pueblo, pueblo_magico).
normalizar_tipo(cultural, cultura).
normalizar_tipo(cultura, cultura).
normalizar_tipo(playa, playa).
normalizar_tipo(pueblo_magico, pueblo_magico).
normalizar_tipo(naturaleza, naturaleza).
normalizar_tipo(cualquiera, cualquiera).

% Convertir una recomendacion en diccionario

resultado(Presupuesto, Dias, Medio, Tipo, R) :-
    recomendar(Presupuesto, Dias, Medio, Tipo,
              Destino, Costo),
    dinero_restante(Presupuesto, Costo, Restante),
    clasificacion(Presupuesto, Costo, Clase),
    destino(Destino, Estado, Categoria),
    format(atom(Explicacion),
           'Viaje ~w. Te sobran $~w MXN.',
           [Clase, Restante]),
    R = _{
        destino:Destino,
        estado:Estado,
        tipo:Categoria,
        costo:Costo,
        explicacion:Explicacion
    }.

% Obtener todas las recomendaciones

planear(Presupuesto, Dias, Medio, Tipo, Lista) :-
    findall(R,
            resultado(Presupuesto, Dias,
                      Medio, Tipo, R),
            Lista).

% Leer argumentos enviados desde Python

% Buscar el destino mas economico de una categoria
alternativa(Dias, Medio, Tipo, Destino, Costo) :-
    findall(
        C-N,
        (
            destino(N, _, Categoria),
            tipo_valido(Categoria, Tipo),
            costo_total(N, Dias, Medio, C)
        ),
        Opciones
    ),
    Opciones \= [],
    sort(Opciones, [Costo-Destino|_]).
% Enviar resultados y alternativas a Python

 % Enviar resultados y alternativas a Python

main :-
    current_prolog_flag(argv, Args),
    (
        Args = [PTexto, DTexto, MTexto, TTexto],
        catch(atom_number(PTexto, Presupuesto), _, fail),
        catch(atom_number(DTexto, Dias), _, fail),
        Presupuesto > 0,
        integer(Dias),
        Dias >= 1,
        normalizar_transporte(MTexto, Medio),
        normalizar_tipo(TTexto, Tipo)
    ->
        (
            planear(Presupuesto, Dias, Medio, Tipo, Lista)
        ->
            true
        ;
            Lista = []
        ),
        (
            Lista \= []
        ->
            Respuesta = _{
                resultados:Lista,
                alternativa:null
            }
        ;
            (
                once(alternativa(Dias, Medio, Tipo, Destino, Costo))
            ->
                Falta is max(0, Costo - Presupuesto),
                Respuesta = _{
                    resultados:[],
                    alternativa:_{
                        destino:Destino,
                        costo:Costo,
                        faltante:Falta
                    }
                }
            ;
                Respuesta = _{
                    resultados:[],
                    alternativa:null
                }
            )
        )
    ;
        Respuesta = _{
            resultados:[],
            alternativa:null
        }
    ),
    json_write_dict(current_output, Respuesta),
    nl.