// Este archivo centraliza los "números mágicos" y catálogos fijos del
// dominio de Cancha, para no repetirlos sueltos por todo el código y
// para que cada valor quede trazado al requerimiento (RF) o regla de
// negocio (RN) del PRD que lo justifica.

/// Constantes generales de la aplicación Cancha.
///
/// El constructor privado `AppConstants._()` evita que alguien intente
/// hacer `AppConstants()` por error: esta clase solo sirve como
/// "espacio de nombres" para constantes estáticas, nunca se instancia.
class AppConstants {
  AppConstants._();

  static const String appName = 'HandPlay';
  static const String ligaNombre = 'Liga de Balonmano del Caquetá';
}