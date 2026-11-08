# Validación de Neón y Colmillos RPG v0.2.0

Fecha: 8 de noviembre de 2026.

Código compilado: `afce672fc395fc9dba3e556615d998856272fc27`.

[GitHub Actions: compilación y pruebas satisfactorias](https://github.com/diroka77-pixel/Neon-y-Colmillos-RPG/actions/runs/42510669222).

## Resultado

APK ARM64 de prueba, versión 0.2.0, versionCode 2, paquete `com.diroka.neonycolmillos`. Tamaño: 24 158 759 bytes. Firma APK v1/v2/v3 verificada. La copia descargada coincide con el SHA-256 calculado en Actions:

`083ac0947d42dd69b91910d644de65f1d7e592a0528d8cb941c61f4aa547b8ce`

## Revisión técnica

Se leyeron íntegramente los siete archivos iniciales: `.github/workflows/android.yml`, `.gitignore`, `README.md`, `export_presets.cfg`, `project.godot`, `scenes/main.tscn` y `scripts/main.gd`. No había recursos gráficos de protagonistas ni AGENTS.md en el árbol inicial.

Se corrigieron la configuración de SDK/Java y de importación de texturas móviles, la renovación de firma en cada build, la falta de enlaces WASD, la pérdida de intensidad analógica al normalizar el joystick, los límites de colisión y el redibujado continuo del mapa completo. El escenario separa suelo estático, edificios, actores y efectos. Se añadió ordenación de profundidad y transparencia de fachadas que ocultan al marcador.

## Pruebas realizadas

- Godot oficial 4.3: importación, análisis de scripts y arranque headless sin errores.
- 291 comprobaciones automáticas satisfactorias.
- 50 semillas: punto inicial libre, conectividad de todas las calles caminables y acceso a los tres terminales mediante recorrido BFS.
- Repetición de semilla, variación entre semillas y conversión entre suelo y pantalla.
- Colisiones con edificios y límites, incluso con desplazamientos grandes.
- Velocidad analógica, dos dedos para movimiento/carrera, liberación de controles y pérdida de foco.
- Activación única de terminales, guardado, carga y reinicio conservando la semilla.
- Ocultación de fachadas y rechazo de recursos canónicos sin aprobación.
- Android API 29 x86_64: instalación de una exportación de pruebas independiente, carga efectiva de escena, activación de terminal mediante toque, movimiento mediante arrastre, segundo plano y reapertura en frío.
- Captura Android revisada: escenario y controles visibles, sin recortes en esa resolución; progreso 1/3 conservado tras reapertura.
- Registro final Android sin errores de Godot ni fallos fatales. El emulador usa ANGLE/SwiftShader (`swangle`); el controlador anterior tenía un límite insuficiente de uniformes para un shader interno de Godot.
- Firma, versión y arquitectura de la APK ARM64 verificadas por herramientas Android.

Las capturas y los registros completos están en el artefacto QA de la ejecución enlazada. No se publicó en Google Play.

## Pendiente

La APK ARM64 no se ha instalado en un teléfono físico. Falta comprobar instalación, fluidez sostenida, consumo y márgenes de pantalla en el Samsung Galaxy S25 Ultra. La prueba Android automatizada usa x86_64 y no sustituye esa comprobación.

El escenario es una primera interpretación geométrica procedural de estética isométrica cyberpunk. Falta el acabado artístico definitivo. Diroka, Sora y Vane conservan la misma prioridad de fidelidad y aún no aparecen: se usa un marcador técnico. Su integración exige sprites y animaciones aprobados, sin modificar sus implantes ni emplear recortes defectuosos.

Esta versión permite exploración y terminales de prueba. No contiene todavía campaña, combate, inventario ni compañeros jugables. La repetibilidad del mapa queda fijada al algoritmo actual y a Godot 4.3.
