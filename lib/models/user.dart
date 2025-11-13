/// Modelo User adaptado al backend de FincaSmart
/// Backend: User { id, nombre, email, telefono, password, activo, fechaRegistro }
class User {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final bool activo;
  final String? fechaRegistro;
  final String? password; // Solo para enviar al backend, nunca se recibe

  const User({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    this.activo = true,
    this.fechaRegistro,
    this.password,
  });

  // Factory constructor para crear desde JSON del backend
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(), // Backend devuelve Long, convertir a String
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String? ?? '',
      activo: json['activo'] as bool? ?? true,
      fechaRegistro: json['fechaRegistro'] as String?,
    );
  }

  // Método para convertir a JSON (para enviar al backend al CREAR)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
    };

    // Solo incluir password si existe (para registro/actualización)
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }

    // No incluir id, activo, fechaRegistro al crear (el backend los asigna)
    return data;
  }

  // Método para enviar al backend al ACTUALIZAR (incluye todos los campos)
  Map<String, dynamic> toJsonUpdate() {
    final Map<String, dynamic> data = {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
    };

    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }

    return data;
  }

  // Método copyWith
  User copyWith({
    String? id,
    String? nombre,
    String? email,
    String? telefono,
    bool? activo,
    String? fechaRegistro,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      activo: activo ?? this.activo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      password: password ?? this.password,
    );
  }

  // Getters útiles
  String get iniciales {
    if (nombre.isEmpty) return '';
    final palabras = nombre.split(' ');
    if (palabras.length >= 2) {
      return '${palabras[0][0]}${palabras[1][0]}'.toUpperCase();
    }
    return nombre[0].toUpperCase();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, nombre: $nombre, activo: $activo)';
  }
}

// Clase para datos de registro (enviar al backend)
// Backend RegisterRequest: { nombre, email, telefono, password }
class RegisterRequest {
  final String nombre;
  final String email;
  final String telefono;
  final String password;

  const RegisterRequest({
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'password': password,
    };
  }

  // Validaciones
  bool get emailValido =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  bool get passwordValido => password.length >= 6;
  bool get nombreValido => nombre.trim().isNotEmpty;
  bool get telefonoValido => telefono.trim().isNotEmpty;
  bool get esValido =>
      emailValido && passwordValido && nombreValido && telefonoValido;

  List<String> get errores {
    final errores = <String>[];
    if (!nombreValido) errores.add('El nombre es requerido');
    if (!emailValido) errores.add('Email no válido');
    if (!telefonoValido) errores.add('El teléfono es requerido');
    if (!passwordValido)
      errores.add('La contraseña debe tener al menos 6 caracteres');
    return errores;
  }
}

// Clase para datos de login (enviar al backend)
// Backend LoginRequest: { email, password }
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  // Validaciones
  bool get emailValido => email.isNotEmpty && email.contains('@');
  bool get passwordValido => password.isNotEmpty;
  bool get esValido => emailValido && passwordValido;
}

// Clase para respuesta de autenticación del backend
// Backend AuthResponse: { token, type, id, nombre, email, telefono, activo }
class AuthResponse {
  final String token;
  final String type;
  final User user;

  const AuthResponse({
    required this.token,
    required this.type,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // El backend devuelve token, type y los datos del usuario en el mismo nivel
    return AuthResponse(
      token: json['token'] as String,
      type: json['type'] as String? ?? 'Bearer',
      user: User.fromJson(
        json,
      ), // User.fromJson extrae id, nombre, email, telefono, activo
    );
  }
}

// Clase para resultado de autenticación (uso interno)
class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  const AuthResult.success(this.user) : success = true, error = null;

  const AuthResult.error(this.error) : success = false, user = null;
}
