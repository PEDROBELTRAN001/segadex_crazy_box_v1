# Crazy Box - Etapa 1

Proyecto Godot 4.7. Abre `project.godot` y ejecuta la escena principal.

## Flujo

`DEMO_IDLE -> PRIZE_INTRO -> READY_TO_HIT -> SCORE_RISE -> SHOW_WIN / SHOW_LOSE -> PRIZE_SELECT -> DEMO_IDLE`

La presentación muestra los premios habilitados antes del golpe. El golpe se simula escribiendo un número entre 0 y 9999 y confirmando con ENTER. Se gana cuando el golpe alcanza o supera el récord de al menos un premio habilitado. En PRIZE_SELECT solo se puede elegir uno de esos premios. Igualar el récord cuenta como alcanzarlo.

Ambos resultados pasan por PRIZE_SELECT: tras una derrota se muestra que no hay premio para reclamar y ENTER regresa al inicio. Tras una victoria, hay que seleccionar un premio y confirmar con ENTER para terminar.

## Datos de la jugada

`SessionManager.hit_score` permanece en memoria hasta volver a DEMO_IDLE. Al confirmar el golpe, `hit_confirmed` impide sobrescribirlo. Elegir o cambiar de premio no modifica ni el golpe ni el resultado. Esto prepara el punto de entrada para una futura lectura de hardware; no guarda el golpe en disco.

Al comenzar se toma una copia de los premios habilitados y sus récords (`round_prizes`). SCORE_RISE determina `eligible_prizes` con esa copia. F5 recarga la configuración para la siguiente jugada sin alterar la actual. DEMO_IDLE limpia golpe, confirmación, resultado, premio elegido y copias de la jugada; R también provoca esa limpieza.

## Teclado

| Tecla | Acción |
| --- | --- |
| ENTER | Comenzar, avanzar o confirmar según el estado |
| 0-9 / teclado numérico | Escribir el golpe en READY_TO_HIT |
| Backspace | Corregir el golpe antes de confirmarlo |
| 1-6 / teclado numérico | Elegir un premio alcanzado en PRIZE_SELECT |
| W | Probar WIN en SCORE_RISE si el golpe alcanzó algún premio |
| L | Forzar LOSE de prueba en SCORE_RISE |
| F1 | Mostrar/ocultar diagnóstico sin cambiar el estado |
| F5 | Recargar `data/prizes_config.json` |
| R | Cancelar la jugada y volver a DEMO_IDLE |

SCORE_RISE avanza automáticamente después de 1,5 segundos. ENTER permite adelantar el resultado; W/L actúan durante esa espera. W requiere un golpe suficiente para mantener coherente la selección posterior.

## Configuración

`data/prizes_config.json` conserva los slots, nombres, habilitación, récords, tendencia, orden y campos de comercio/media. Edita el JSON y presiona F5. Si no hay premios habilitados, el inicio se bloquea hasta corregir la configuración. Los récords no se descuentan automáticamente ni se restauran desde `record_fijo` al recargar.

El diagnóstico muestra los valores cargados y las variables de la sesión. La interfaz es temporal, con textos y desplazamiento para pantallas pequeñas.

## Relación con el documento

Se conserva la estructura de estados, configuración local y diagnóstico de la Etapa 1. La solicitud del proyecto modifica el orden original: la elección del premio ocurre después del golpe y del resultado. Se añade la comparación simulada del golpe para filtrar premios. El descuento de récords queda fuera del flujo, como indica el alcance de la etapa. No se integra hardware ni se entrega físicamente el premio.

`scenes/Main.gd` coordina los estados y la pantalla. `scripts/Main.gd` hereda esa implementación para evitar mantener un segundo flujo distinto.

## Prueba automática

Ejecuta con el binario de Godot disponible en tu equipo:

```powershell
godot --headless --path . tests/test_flow.tscn
```

La prueba recorre victoria y derrota, igualdad de récord, selección con teclado numérico, rechazo de premios no alcanzados/deshabilitados, recarga de configuración, conservación del golpe, reinicio durante el temporizador, avance automático y falta de premios activos. Usa premios temporales en memoria y no modifica el JSON.
