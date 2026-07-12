# Experimentación

## Experimentación técnica mediante simulación controlada

En la fase de experimentación se evaluó el funcionamiento del prototipo SOFO mediante un escenario controlado de simulación de un recorrido de transporte público. Esta etapa tuvo como propósito comprobar la comunicación entre la aplicación del conductor, el servidor central, la base de datos y la aplicación del pasajero, así como verificar la generación oportuna de indicaciones durante las diferentes etapas del viaje.

Debido a que el prototipo se encuentra en una fase inicial de desarrollo y todavía no emplea unidades de transporte reales, el desplazamiento del corredor fue representado mediante coordenadas geográficas simuladas. Esta decisión permitió reproducir de forma controlada y repetible el avance de una unidad por una ruta definida, evitando que factores externos, como el tráfico, la disponibilidad de vehículos o las variaciones en la señal GPS, interfirieran en la validación técnica.

La experimentación se realizó utilizando dos aplicaciones Flutter independientes. La primera correspondió a la aplicación del conductor, encargada de iniciar y finalizar el recorrido, así como de enviar periódicamente la ubicación de la unidad. La segunda correspondió a la aplicación del pasajero, responsable de representar el proceso de orientación desde la confirmación del paradero de origen hasta la llegada al destino. Ambas aplicaciones se comunicaron con un backend desarrollado en Node.js y JavaScript, mientras que la información de los recorridos y ubicaciones fue almacenada en una base de datos PostgreSQL administrada mediante Supabase.

Para representar el movimiento del corredor 201 se configuró una ruta simulada compuesta por cinco paraderos. La unidad inició su recorrido en el paradero La Positiva, continuó por Ricardo Palma, Guardia Civil y Aviación, y finalizó en San Luis. Entre cada paradero se generaron posiciones intermedias para representar el desplazamiento progresivo del vehículo. Las coordenadas fueron enviadas al backend cada tres segundos. Asimismo, al llegar a cada paradero, la unidad permaneció detenida durante diez segundos, simulando el tiempo requerido para el ascenso y descenso de pasajeros.

## Objetivo de la experimentación

El objetivo de esta fase fue validar el funcionamiento integrado de los componentes de SOFO durante la simulación de un viaje en un corredor de transporte público. Específicamente, se buscó comprobar que:

- La aplicación del conductor pudiera iniciar y finalizar un recorrido.
- La ubicación de la unidad fuera enviada periódicamente al backend.
- Las coordenadas fueran almacenadas correctamente en la base de datos.
- La aplicación del pasajero pudiera identificar un corredor activo.
- El sistema determinara el paradero asociado con la ubicación de la unidad.
- El pasajero recibiera información sobre la cantidad de paraderos restantes.
- Se generara una solicitud de confirmación cuando la unidad llegara al paradero de abordaje.
- Se mostrara una alerta preventiva un paradero antes del destino.
- Se confirmara la llegada al paradero de destino.

## Arquitectura empleada

La arquitectura utilizada durante la experimentación estuvo conformada por los siguientes componentes:

| Componente | Tecnología | Función |
|---|---|---|
| Aplicación del conductor | Flutter | Iniciar el recorrido y transmitir la ubicación simulada de la unidad |
| Aplicación del pasajero | Flutter | Recibir orientación, seguimiento y alertas durante el viaje |
| Backend central | Node.js y JavaScript | Gestionar recorridos, procesar ubicaciones y comunicar ambas aplicaciones |
| Comunicación en tiempo real | Socket.IO | Enviar actualizaciones de ubicación a la aplicación del pasajero |
| API de operaciones | REST/HTTP | Iniciar, consultar y finalizar recorridos |
| Base de datos | PostgreSQL mediante Supabase | Almacenar recorridos, ubicación actual e historial de posiciones |

El flujo general de información fue el siguiente:

```text
Aplicación del conductor
          │
          │ HTTP: inicio, ubicación y finalización
          ▼
     Backend SOFO
          │
          ├──────────────► Supabase/PostgreSQL
          │                 Almacenamiento
          │
          │ Socket.IO: ubicación actualizada
          ▼
Aplicación del pasajero
```

## Ruta simulada

La ruta utilizada en la experimentación estuvo formada por los siguientes paraderos:

| Orden | Paradero | Latitud | Longitud | Función en el experimento |
|---:|---|---:|---:|---|
| 1 | La Positiva | `-12.091378` | `-77.026176` | Inicio del recorrido |
| 2 | Ricardo Palma | `-12.090196` | `-77.017311` | Paradero intermedio |
| 3 | Guardia Civil | `-12.088926` | `-77.008042` | Abordaje del pasajero |
| 4 | Aviación | `-12.088480` | `-77.004552` | Alerta previa al destino |
| 5 | San Luis | `-12.087383` | `-76.996908` | Destino final |

El recorrido fue dividido en posiciones intermedias para evitar que la ubicación de la unidad cambiara directamente de un paradero a otro. Cada nueva posición se generó y transmitió en intervalos de tres segundos. Al alcanzar un paradero, la simulación realizó una pausa de diez segundos antes de continuar hacia el siguiente punto.

## Escenario experimental

El escenario representó el viaje de una persona con discapacidad visual que se encontraba esperando en el paradero Guardia Civil y deseaba trasladarse hasta el paradero San Luis mediante el corredor 201.

En este escenario, la unidad inició su recorrido en La Positiva. Mientras el pasajero permanecía en Guardia Civil, la aplicación debía informar progresivamente la aproximación del corredor. Cuando la unidad alcanzaba Guardia Civil, el sistema solicitaba al pasajero confirmar que había abordado. Posteriormente, la aplicación continuaba monitoreando la posición del corredor hasta generar una alerta en Aviación y confirmar la llegada en San Luis.

## Entorno de experimentación

La simulación se ejecutó utilizando la siguiente configuración:

| Elemento | Configuración utilizada |
|---|---|
| Corredor | 201 |
| Identificador de unidad | `bus-201-01` |
| Paradero de origen del pasajero | Guardia Civil |
| Paradero de destino | San Luis |
| Intervalo de actualización | 3 segundos |
| Tiempo de permanencia en paradero | 10 segundos |
| Aplicación del conductor | Emulador Android |
| Aplicación del pasajero | Dispositivo Android físico |
| Servidor | Backend Node.js ejecutado en la red local |
| Base de datos | Supabase/PostgreSQL |
| Comunicación | HTTP y Socket.IO |

> **Nota para la versión final:** agregar las especificaciones del equipo, versión del sistema operativo, modelo del dispositivo móvil y versiones principales de las herramientas utilizadas.

## Procedimiento experimental

La ejecución del escenario se desarrolló mediante el siguiente procedimiento:

1. Se inició el backend y se verificó su conexión con Supabase.
2. Se ejecutó la aplicación del conductor en un emulador Android.
3. Se ejecutó la aplicación del pasajero en un dispositivo Android físico.
4. En la aplicación del pasajero se seleccionó la opción **Iniciar viaje**.
5. El sistema simuló la detección del pasajero en el paradero Guardia Civil.
6. El usuario confirmó que se encontraba en dicho paradero.
7. Se accedió a la pantalla destinada a reconocer por voz el paradero de destino.
8. Debido a que el reconocimiento de voz todavía no formaba parte de la versión evaluada, se utilizó la opción **Simular destino detectado**.
9. El sistema estableció San Luis como destino y asignó el corredor 201.
10. El pasajero confirmó que esperaría la llegada del corredor asignado.
11. Desde la aplicación del conductor se inició el recorrido simulado.
12. La aplicación del conductor envió periódicamente las coordenadas de la unidad al backend.
13. El backend almacenó la ubicación actual y su historial en Supabase.
14. La aplicación del pasajero consultó el corredor activo y se suscribió a sus actualizaciones mediante Socket.IO.
15. Cuando la unidad se encontraba en La Positiva, la aplicación informó que faltaban dos paraderos para Guardia Civil.
16. Al llegar a Ricardo Palma, la aplicación informó que faltaba un paradero.
17. Al alcanzar Guardia Civil, el sistema indicó que la unidad había llegado y solicitó la confirmación de abordaje.
18. El pasajero confirmó que se encontraba dentro del corredor 201.
19. La aplicación inició el seguimiento del viaje hacia San Luis.
20. Al alcanzar Aviación, el sistema informó que faltaba un paradero para llegar al destino.
21. Al alcanzar San Luis, la aplicación confirmó la llegada al destino final.
22. Finalmente, desde la aplicación del conductor se finalizó el recorrido y se verificó su actualización en la base de datos.

## Variables e indicadores técnicos

La validación se centró en el comportamiento funcional del sistema. Para ello, se definieron las siguientes dimensiones e indicadores:

| Dimensión | Indicador | Criterio de aceptación |
|---|---|---|
| Conectividad | Comunicación entre aplicaciones y backend | Ambas aplicaciones acceden correctamente al servidor |
| Persistencia | Registro de recorridos y ubicaciones | Los registros se almacenan en Supabase sin pérdida de información |
| Actualización | Recepción de coordenadas | La aplicación del pasajero recibe los cambios de posición |
| Reconocimiento | Identificación del paradero | El sistema relaciona correctamente las coordenadas con un paradero |
| Orientación | Conteo de paraderos | La cantidad de paraderos restantes se actualiza coherentemente |
| Abordaje | Llegada a Guardia Civil | Se presenta la pantalla de confirmación de abordaje |
| Alerta preventiva | Llegada a Aviación | Se informa que falta un paradero para San Luis |
| Llegada | Llegada a San Luis | Se presenta la confirmación del destino final |
| Recuperación | Reinicio de la simulación | La unidad vuelve a La Positiva y puede comenzar un nuevo recorrido |
| Consistencia | Sincronización entre aplicaciones | El estado mostrado al pasajero coincide con la ubicación del conductor |

## Casos de prueba

Los casos de prueba funcional considerados para la experimentación fueron los siguientes:

| Código | Caso de prueba | Resultado esperado |
|---|---|---|
| CP-01 | Iniciar el recorrido del corredor 201 | Se crea un recorrido con estado activo |
| CP-02 | Enviar la ubicación desde la aplicación del conductor | La coordenada es recibida por el backend |
| CP-03 | Persistir una coordenada | La ubicación aparece en Supabase |
| CP-04 | Consultar el corredor activo | Se obtiene la unidad `bus-201-01` |
| CP-05 | Detectar la unidad en La Positiva | Se informa que faltan dos paraderos para Guardia Civil |
| CP-06 | Detectar la unidad en Ricardo Palma | Se informa que falta un paradero para Guardia Civil |
| CP-07 | Detectar la unidad en Guardia Civil | Se solicita confirmar el abordaje |
| CP-08 | Confirmar el abordaje | Se inicia el seguimiento hacia San Luis |
| CP-09 | Detectar la unidad en Aviación | Se genera la alerta de un paradero restante |
| CP-10 | Detectar la unidad en San Luis | Se confirma la llegada al destino |
| CP-11 | Finalizar el recorrido | El recorrido cambia a estado finalizado |
| CP-12 | Reiniciar la simulación | La ubicación vuelve a La Positiva |
| CP-13 | Iniciar al pasajero antes que al conductor | La aplicación continúa consultando hasta encontrar un corredor activo |
| CP-14 | Interrumpir temporalmente la conexión | La aplicación muestra el problema y permite recuperar el seguimiento |

## Instrumento de observación

Para documentar la ejecución puede emplearse una ficha de observación técnica como la siguiente:

| Ítem evaluado | Cumple | No cumple | Observaciones |
|---|:---:|:---:|---|
| El conductor puede iniciar el recorrido | ☐ | ☐ | |
| El recorrido se registra en Supabase | ☐ | ☐ | |
| La ubicación inicial se almacena correctamente | ☐ | ☐ | |
| Las coordenadas se actualizan durante el recorrido | ☐ | ☐ | |
| El pasajero identifica el corredor activo | ☐ | ☐ | |
| El conteo de paraderos es correcto | ☐ | ☐ | |
| El sistema reconoce la llegada a Guardia Civil | ☐ | ☐ | |
| Se muestra la confirmación de abordaje | ☐ | ☐ | |
| Se genera la alerta preventiva en Aviación | ☐ | ☐ | |
| Se confirma la llegada a San Luis | ☐ | ☐ | |
| El recorrido puede finalizarse | ☐ | ☐ | |
| La simulación puede reiniciarse | ☐ | ☐ | |
| El sistema se recupera de una desconexión temporal | ☐ | ☐ | |

## Registro de resultados

La siguiente tabla puede utilizarse para registrar los resultados de las repeticiones realizadas:

| Ejecución | Inicio correcto | Actualización de ubicación | Abordaje detectado | Alerta en Aviación | Llegada a San Luis | Tiempo de respuesta | Observaciones |
|---:|:---:|:---:|:---:|:---:|:---:|---:|---|
| 1 |  |  |  |  |  |  |  |
| 2 |  |  |  |  |  |  |  |
| 3 |  |  |  |  |  |  |  |
| 4 |  |  |  |  |  |  |  |
| 5 |  |  |  |  |  |  |  |

> **Importante:** completar esta tabla únicamente con resultados observados. No deben incorporarse valores estimados como si hubieran sido medidos.

## Resultados de la validación

Durante la ejecución del escenario simulado se verificó la comunicación entre la aplicación del conductor, el backend, Supabase y la aplicación del pasajero. La aplicación del conductor pudo iniciar el recorrido y transmitir las coordenadas generadas por la simulación. El backend recibió estas coordenadas, actualizó la posición de la unidad y almacenó el historial correspondiente en la base de datos.

Asimismo, la aplicación del pasajero pudo consultar la unidad activa del corredor 201 y recibir actualizaciones de ubicación en tiempo real. A partir de estas actualizaciones, el sistema identificó los paraderos definidos en la ruta y activó las transiciones correspondientes al acercamiento de la unidad, la confirmación de abordaje, la alerta previa y la llegada al destino.

La simulación permitió comprobar el flujo funcional completo desde el inicio del recorrido en La Positiva hasta la llegada a San Luis. No obstante, para presentar resultados cuantitativos relacionados con tiempos de respuesta, porcentaje de casos exitosos o estabilidad de la conexión, será necesario registrar varias ejecuciones mediante la ficha de observación propuesta.

## Limitaciones

La experimentación presentó las siguientes limitaciones:

- La ubicación de la unidad fue simulada y no provino de un receptor GPS instalado en un vehículo real.
- El recorrido no estuvo expuesto a condiciones reales de tráfico, desvíos o pérdida de señal.
- La selección del destino se realizó mediante un botón de simulación y no mediante reconocimiento de voz.
- La ubicación inicial del pasajero fue predefinida en Guardia Civil.
- La evaluación se centró en el funcionamiento técnico del sistema.
- No se evaluó todavía la experiencia de uso con una muestra de personas con discapacidad visual.
- No se midió el efecto del sistema sobre la autonomía, seguridad percibida o confianza de los usuarios.
- La comunicación se realizó dentro de un entorno local de desarrollo y no mediante un backend desplegado para producción.

## Consideraciones éticas y alcance de los resultados

Los resultados de esta fase corresponden a una validación técnica mediante simulación controlada. Por este motivo, no permiten afirmar todavía que SOFO sea usable, accesible o efectivo para todas las personas con discapacidad visual. Tales afirmaciones requerirían una evaluación posterior con usuarios representativos, consentimiento informado, criterios de inclusión y exclusión, instrumentos validados y procedimientos que protejan la seguridad y privacidad de los participantes.

En una etapa posterior se propone realizar pruebas de usabilidad y accesibilidad con personas con discapacidad visual. Esta evaluación podría considerar el cumplimiento de tareas, el tiempo requerido para completar el viaje simulado, la cantidad de errores, la comprensión de las alertas, la carga percibida, la satisfacción y la confianza generada por el sistema.

## Conclusión de la experimentación

La experimentación técnica permitió comprobar la integración funcional de los componentes principales de SOFO bajo condiciones controladas. Se verificó que la aplicación del conductor pudiera generar un recorrido y transmitir posiciones geográficas, que el backend almacenara y procesara dichas actualizaciones y que la aplicación del pasajero reaccionara de acuerdo con la proximidad de la unidad a los paraderos definidos.

El escenario simulado permitió validar la secuencia correspondiente a la espera del corredor, aproximación a Guardia Civil, confirmación de abordaje, seguimiento dentro de la unidad, alerta preventiva en Aviación y llegada a San Luis. De esta forma, se obtuvo evidencia funcional sobre la viabilidad técnica de la propuesta antes de realizar pruebas en un entorno de transporte real.

Sin embargo, esta etapa no sustituye una evaluación con usuarios finales. Como trabajo posterior, se plantea incorporar GPS real, reconocimiento de voz, despliegue remoto del backend y pruebas controladas con personas con discapacidad visual, con el objetivo de evaluar no solo el funcionamiento del sistema, sino también su accesibilidad, usabilidad y contribución a la autonomía durante el uso del transporte público.

## Diferencia entre la etapa actual y una evaluación con usuarios

| Validación técnica actual | Evaluación posterior con usuarios |
|---|---|
| Utiliza coordenadas simuladas | Utiliza GPS o recorridos reales |
| Comprueba la integración del sistema | Evalúa accesibilidad y experiencia de uso |
| Se ejecuta en un entorno controlado | Se ejecuta con participantes representativos |
| Analiza respuestas del software | Analiza desempeño y percepción del usuario |
| No mide satisfacción real | Puede utilizar cuestionarios, entrevistas y escalas |
| No demuestra impacto sobre la autonomía | Puede aportar evidencia sobre autonomía y seguridad |

---

### Información pendiente para la versión final

Antes de incorporar esta sección a la tesis, se recomienda completar:

1. Número exacto de ejecuciones realizadas.
2. Fecha y lugar de la experimentación.
3. Especificaciones del equipo utilizado.
4. Modelo y versión del dispositivo móvil.
5. Versiones de Flutter, Node.js y demás herramientas relevantes.
6. Resultados observados en cada caso de prueba.
7. Tiempos de respuesta medidos.
8. Incidencias detectadas y acciones correctivas.
9. Evidencias visuales del conductor, pasajero, backend y Supabase.
10. Referencias metodológicas empleadas por la investigación.
