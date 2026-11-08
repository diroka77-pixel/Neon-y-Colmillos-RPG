# Neón y Colmillos — Godot v0.2.0

Prototipo de exploración cyberpunk pixel art 2.5D para Android. Escenario isométrico procedural determinista, edificios con profundidad, lluvia, joystick analógico, terminales interactivos y guardado local.

No incluye todavía los sprites canónicos de Diroka, Sora y Vane. El arte provisional no representa a esos personajes.

## Ejecutar
Abrir `project.godot` en **Godot 4.3 estable** y ejecutar la escena principal. WASD/flechas: mover; Shift: correr; E/espacio: usar. En móvil: joystick izquierdo, mantener CORRER y pulsar USAR cerca de un terminal. REINICIAR conserva la semilla y elimina el progreso de exploración.

## Android
El workflow `Android APK` importa y prueba el proyecto, captura el escenario, exporta y verifica la firma de una APK ARM64, y ejecuta una prueba Android API 29 con una exportación x86_64 independiente. Solo entrega el artefacto APK cuando esos pasos terminan correctamente. Cada ejecución conserva registros y capturas en el artefacto QA.

La firma de prueba es estable entre compilaciones. La clave de `ci/` es pública y exclusiva de depuración. No se publica en Google Play. El repositorio no contiene la firma de producción.

## Verificación local

`bash ci/check.sh /ruta/al/ejecutable/godot-4.3`

Comprueba repetibilidad, 50 semillas, conectividad de calles, acceso a terminales, límites, colisiones, intensidad analógica, entrada con dos dedos, pérdida de foco, persistencia y montaje de la escena. El modo headless no acredita calidad gráfica ni rendimiento en un teléfono; las capturas y el emulador son verificaciones adicionales. La instalación y fluidez en un Samsung real requieren prueba física.

Consulta `docs/ARCHITECTURE.md` y `CHANGELOG.md` para el diseño y los cambios.

## Canon
Conservar intactos los diseños y el lore aprobados de Neón y Colmillos. No introducir imágenes recortadas defectuosas.
