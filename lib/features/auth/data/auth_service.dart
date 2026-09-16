import 'package:firebase_auth/firebase_auth.dart'; // Importamos la librería de Firebase Auth para poder usar sus clases y métodos de autenticación
import 'package:google_sign_in/google_sign_in.dart'; // Importamos la librería de Google Sign-In para poder usar sus clases y métodos de autenticación con Google

// Esta clase `AuthService` encapsula la lógica de autenticación de la app, usando Firebase Auth y Google Sign-In. Proporciona métodos para iniciar sesión, registrarse, iniciar sesión con Google y enviar correos de recuperación de contraseña. También maneja los errores de autenticación y devuelve mensajes amigables para el usuario.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance; // Si se pasa una instancia de FirebaseAuth, se usa esa; si no, se usa la instancia por defecto de FirebaseAuth. Esto permite inyectar un mock de FirebaseAuth para pruebas unitarias.

  final FirebaseAuth _auth; // Instancia de FirebaseAuth que se usa para realizar operaciones de autenticación. Se inicializa en el constructor, permitiendo inyección de dependencias para pruebas.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance; // Instancia de GoogleSignIn que se usa para realizar operaciones de autenticación con Google. Se inicializa con la instancia por defecto de GoogleSignIn.
  bool _googleInitialized = false; // Bandera que indica si se ha inicializado la autenticación con Google. Se usa para evitar inicializarla varias veces.

  // Métodos de autenticación
  Future<UserCredential> signIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(), // Eliminamos espacios en blanco al inicio y al final del correo electrónico antes de enviarlo a Firebase Auth
      password: password, // La contraseña se envía tal cual, sin modificarla, ya que Firebase Auth la maneja de forma segura
    );
  }
  // El método `register` crea un nuevo usuario en Firebase Auth con el correo electrónico y la contraseña proporcionados, y luego actualiza el nombre para mostrar del usuario con el valor proporcionado. Devuelve un `UserCredential` que contiene información sobre el usuario autenticado.
  Future<UserCredential> register({required String email, required String password, required String displayName}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(displayName.trim());
    return credential;
  }

  // El método `signInWithGoogle` inicia el flujo de autenticación con Google. Primero, verifica si la autenticación con Google ya se ha inicializado; si no, la inicializa. Luego, solicita al usuario que seleccione una cuenta de Google y obtiene un token de ID. Con ese token, crea una credencial de Firebase Auth y la usa para iniciar sesión en Firebase. Devuelve un `UserCredential` que contiene información sobre el usuario autenticado.
  Future<UserCredential> signInWithGoogle() async {
    if (!_googleInitialized) {
      await _googleSignIn.initialize();
      _googleInitialized = true;
    }
    final account = await _googleSignIn.authenticate();
    final authentication = account.authentication;
    final credential = GoogleAuthProvider.credential(idToken: authentication.idToken);
    return _auth.signInWithCredential(credential);
  }

  // El método `sendPasswordResetEmail` envía un correo electrónico de recuperación de contraseña al correo proporcionado. Devuelve un `Future<void>` que se completa cuando la operación termina.
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }
}

// La función `authErrorMessage` toma un objeto de error (generalmente una excepción de Firebase Auth) y devuelve un mensaje amigable para el usuario según el código de error. Si el error no es un `FirebaseAuthException`, devuelve un mensaje genérico de error.
String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'El correo o la contraseña no son correctos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'Introduce un correo electrónico válido.';
      case 'network-request-failed':
        return 'No hay conexión. Comprueba tu conexión a internet.';
      case 'popup-closed-by-user':
        return 'Se canceló el inicio de sesión con Google.';
      default:
        return error.message ?? 'No se pudo completar la operación.';
    }
  }
  return 'No se pudo completar la operación. Inténtalo de nuevo.';
}