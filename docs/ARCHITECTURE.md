# Arquitectura v0.2.0

Godot 4.3 estable, GDScript y renderizador Compatibility. Sin servicios externos, plugins de pago ni recursos de terceros.

## Capas

| Archivo | Responsabilidad |
| --- | --- |
| `world_generator.gd` | Semilla local, edificios, ocupación, proyección isométrica y colisiones en coordenadas lógicas. |
| `ground.gd` | Pavimento, marcas, charcos, sombras y reflejos estáticos. |
| `building.gd` | Fachadas, tejados, ventanas y elementos industriales de cada edificio. |
| `player.gd` | Marcador técnico, movimiento analógico y colisión por subpasos. |
| `touch_controls.gd` | Joystick, correr, usar, reinicio y márgenes seguros. |
| `beacon.gd` | Terminal de exploración provisional, sin contenido narrativo canónico. |
| `weather.gd` | Lluvia decorativa limitada a 90 trazos en pantalla. |
| `main.gd` | Montaje, cámara, interacciones y persistencia local. |
| `character_definition.gd` | Recurso de integración de arte aprobado. |

La geometría del suelo y los edificios se conserva en las listas de dibujo de Godot. Solo la lluvia y los controles se redibujan continuamente. `y_sort_enabled` ordena edificios, terminales y marcador por la base en pantalla. Las fachadas que ocultan al marcador reducen su opacidad para mantenerlo visible. La perspectiva es una proyección 2D isométrica; no se necesita geometría 3D.

## Generación

Semilla inicial: **1984**. El algoritmo se versiona por separado (`generator_version=1`). Cada regeneración crea un `RandomNumberGenerator` local y reinicia su semilla. La lluvia, el framerate y la entrada no consumen ese RNG. La distribución usa huellas rectangulares separadas por corredores conectados. Los tests recorren todas las celdas caminables mediante BFS y comprueban acceso a los tres terminales en 50 semillas.

La repetibilidad queda definida para el algoritmo actual y Godot 4.3. Una actualización del motor o del algoritmo exige revisar la compatibilidad del guardado y aumentar su versión. No se promete el mismo mapa entre versiones distintas del motor.

## Android

Horizontal, pantalla completa, OpenGL Compatibility y APK ARM64. Controles independientes por índice de dedo, zona muerta de 12 %, velocidad proporcional y botón de correr mantenido. La pérdida de foco, la pausa o un cambio de tamaño limpian las entradas. Se guarda posición y terminales cada cinco segundos, al pausar y al salir. Una posición inválida vuelve al punto inicial. `REINICIAR` borra el progreso de exploración conservando la semilla.

La compilación fija Java 17 y escribe explícitamente las rutas SDK de Android y Java en los ajustes de Godot. Se habilita `textures/vram_compression/import_etc2_astc`: Godot 4.3 rechaza la configuración de exportación Android sin esa opción y no explica el motivo en el error CLI. El ejecutable del motor y las plantillas se descargan fuera del proyecto para evitar empaquetarlos. La clave pública de depuración en `ci/debug.keystore.b64` se conserva entre builds: sirve exclusivamente para instalar pruebas encima de otras pruebas de este repositorio. No debe emplearse para distribución de producción.

## Diroka, Sora y Vane

El marcador no representa a ninguno de ellos. Cada uno requiere su propia referencia canónica aprobada y `SpriteFrames` completos, con idéntico criterio de fidelidad para los tres. `CharacterDefinition.can_integrate()` comprueba esos campos antes de una futura integración; actualmente no se carga ningún personaje canónico en el juego. Mantener rostro, cuerpo, pelo, vestuario, accesorios e implantes aprobados. No usar recortes de fichas defectuosos. No se inventan diseños ni se modifica el lore.

La integración posterior puede sustituir el dibujo del marcador por `AnimatedSprite2D`, conservando coordenadas de suelo, colisiones, controles y punto de ordenación a los pies. Faltan sprites y animaciones aprobados, combate, compañeros, diálogos, inventario y campaña.
