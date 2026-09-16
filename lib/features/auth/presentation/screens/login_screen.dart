import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../shared/widgets/app_bottom_navigation_bar.dart'; // Importamos el widget de barra de navegación inferior para poder usarlo en la pantalla de login
import '../../data/auth_service.dart'; // Importamos el servicio de autenticación para poder usarlo en la pantalla de login

// La pantalla de login permite al usuario iniciar sesión con su correo electrónico y contraseña, o con su cuenta de Google. También permite al usuario navegar a la pantalla de registro o a la pantalla de recuperación de contraseña.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// La clase `_LoginScreenState` es el estado de la pantalla de login. Contiene los controladores de texto para el correo electrónico y la contraseña, un indicador de carga, y métodos para manejar la autenticación y la navegación.
class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(); // Controlador de texto para el campo de correo electrónico, que permite obtener y modificar el valor del campo de texto en la pantalla de login
  final _password = TextEditingController(); // Controlador de texto para el campo de contraseña, que permite obtener y modificar el valor del campo de texto en la pantalla de login
  final _auth = AuthService(); // Instancia del servicio de autenticación, que permite acceder a los métodos de autenticación como `signIn`, `register`, `signInWithGoogle` y `sendPasswordResetEmail`
  bool _loading = false; // Indicador de carga que se usa para mostrar un `CircularProgressIndicator` mientras se realiza una operación de autenticación, y deshabilitar los botones de la pantalla de login para evitar múltiples solicitudes simultáneas

  @override
  void dispose() {
    _email.dispose(); // Liberamos los recursos del controlador de texto del correo electrónico cuando el widget se desmonta para evitar fugas de memoria
    _password.dispose(); // Liberamos los recursos del controlador de texto de la contraseña cuando el widget se desmonta para evitar fugas de memoria
    super.dispose(); // Llamamos a `super.dispose()` para asegurarnos de que cualquier limpieza adicional del estado del widget se realice correctamente cuando el widget se desmonta
  }

  // El método `_run` ejecuta una acción de autenticación y maneja el estado de carga y los errores. Si la acción se completa con éxito, navega a la pantalla de inicio; si ocurre un error, muestra un `SnackBar` con un mensaje amigable para el usuario.
  Future<void> _run(Future<void> Function() action) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await action();
      if (mounted) context.go(RouteNames.home); // Navegamos a la pantalla de inicio (`RouteNames.home`) después de que la acción de autenticación se complete con éxito, usando `context.go` de `go_router` para reemplazar la pantalla actual en la pila de navegación y evitar que el usuario pueda volver a la pantalla de login con el botón de retroceso.
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authErrorMessage(error)))); // Mostramos un `SnackBar` con un mensaje amigable para el usuario según el error de autenticación, usando la función `authErrorMessage` que mapea los códigos de error de Firebase Auth a mensajes legibles.
      }
    } finally {
      if (mounted) setState(() => _loading = false); // Restauramos el estado de carga a `false` después de que la acción de autenticación se complete o falle, para habilitar los botones de la pantalla de login nuevamente.
    }
  }

// La función `authErrorMessage` toma un objeto de error (generalmente una excepción de Firebase Auth) y devuelve un mensaje amigable para el usuario según el código de error. Si el error no es un `FirebaseAuthException`, devuelve un mensaje genérico de error.
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Center(child: Container(width: 82, height: 82, decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(20)), child: Icon(AppConstants.appLogoIcon, size: 44, color: colors.onPrimary))),
                const SizedBox(height: 20),
                Text('Bienvenido a ${AppConstants.appName}', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.onSurface)),
                const SizedBox(height: 6),
                Text(AppConstants.ligaNombre, textAlign: TextAlign.center, style: TextStyle(color: colors.onSurfaceVariant)),
                const SizedBox(height: 28),
                TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Correo electrónico')),
                const SizedBox(height: 18),
                TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => context.go(RouteNames.recoverPassword), child: const Text('¿Olvidaste tu contraseña?'))),
                const SizedBox(height: 10),
                FilledButton(onPressed: _loading ? null : () => _run(() async => _auth.signIn(email: _email.text, password: _password.text)), child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Iniciar sesión')),
                const SizedBox(height: 18),
                OutlinedButton.icon(onPressed: _loading ? null : () => _run(() async => _auth.signInWithGoogle()), icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), label: Text(AppConstants.googleButton)),
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('¿No tienes cuenta?', style: TextStyle(color: colors.onSurfaceVariant)), TextButton(onPressed: () => context.go(RouteNames.register), child: const Text('Regístrate'))]),
              ]),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(selectedIndex: 2),
    );
  }
}