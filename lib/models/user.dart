class User {
  final String id;
  final String email;
  final String nombre;
  final String apellido;
  final String? telefono;
  final String? fechaNacimiento;
  final Genero? genero;
  final String? photoUrl;
  final TipoUsuario tipoUsuario;
  final bool verificado;
  final bool activo;
  final String fechaRegistro;
  final String? fechaUltimoAcceso;
  final AuthProvider authProvider;
  final PreferenciasUsuario? preferencias;

  const User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    this.telefono,
    this.fechaNacimiento,
    this.genero,
    this.photoUrl,
    this.tipoUsuario = TipoUsuario.huesped,
    this.verificado = false,
    this.activo = true,
    required this.fechaRegistro,
    this.fechaUltimoAcceso,
    this.authProvider = AuthProvider.email,
    this.preferencias,
  });

  // Factory constructor para crear desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(), // Convertir a String
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String? ?? '', // Puede ser null en respuestas del backend
      telefono: json['telefono'] as String?,
      fechaNacimiento: json['fechaNacimiento'] as String?,
      genero: json['genero'] != null 
          ? Genero.values.firstWhere(
              (g) => g.name == json['genero'],
              orElse: () => Genero.otro,
            )
          : null,
      photoUrl: json['photoUrl'] as String?,
      tipoUsuario: json['tipoUsuario'] != null
          ? TipoUsuario.values.firstWhere(
              (tipo) => tipo.name == json['tipoUsuario'],
              orElse: () => TipoUsuario.huesped,
            )
          : TipoUsuario.huesped,
      verificado: json['verificado'] as bool? ?? false,
      activo: json['activo'] as bool? ?? true,
      fechaRegistro: json['fechaRegistro'] as String? ?? DateTime.now().toIso8601String(),
      fechaUltimoAcceso: json['fechaUltimoAcceso'] as String?,
      authProvider: json['authProvider'] != null
          ? AuthProvider.values.firstWhere(
              (provider) => provider.name == json['authProvider'],
              orElse: () => AuthProvider.email,
            )
          : AuthProvider.email,
      preferencias: json['preferencias'] != null
          ? PreferenciasUsuario.fromJson(json['preferencias'])
          : null,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'fechaNacimiento': fechaNacimiento,
      'genero': genero?.name,
      'photoUrl': photoUrl,
      'tipoUsuario': tipoUsuario.name,
      'verificado': verificado,
      'activo': activo,
      'fechaRegistro': fechaRegistro,
      'fechaUltimoAcceso': fechaUltimoAcceso,
      'authProvider': authProvider.name,
      'preferencias': preferencias?.toJson(),
    };
  }

  // Método copyWith para crear una nueva instancia con cambios
  User copyWith({
    String? id,
    String? email,
    String? nombre,
    String? apellido,
    String? telefono,
    String? fechaNacimiento,
    Genero? genero,
    String? photoUrl,
    TipoUsuario? tipoUsuario,
    bool? verificado,
    bool? activo,
    String? fechaRegistro,
    String? fechaUltimoAcceso,
    AuthProvider? authProvider,
    PreferenciasUsuario? preferencias,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      telefono: telefono ?? this.telefono,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      genero: genero ?? this.genero,
      photoUrl: photoUrl ?? this.photoUrl,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      verificado: verificado ?? this.verificado,
      activo: activo ?? this.activo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      fechaUltimoAcceso: fechaUltimoAcceso ?? this.fechaUltimoAcceso,
      authProvider: authProvider ?? this.authProvider,
      preferencias: preferencias ?? this.preferencias,
    );
  }

  // Getters útiles
  String get nombreCompleto => '$nombre $apellido';
  
  String get iniciales {
    final primerNombre = nombre.isNotEmpty ? nombre[0].toUpperCase() : '';
    final primerApellido = apellido.isNotEmpty ? apellido[0].toUpperCase() : '';
    return '$primerNombre$primerApellido';
  }

  bool get tieneInformacionCompleta {
    return telefono != null && 
           fechaNacimiento != null && 
           genero != null;
  }

  int? get edad {
    if (fechaNacimiento == null) return null;
    try {
      final fechaNac = DateTime.parse(fechaNacimiento!);
      final hoy = DateTime.now();
      int edad = hoy.year - fechaNac.year;
      if (hoy.month < fechaNac.month || 
          (hoy.month == fechaNac.month && hoy.day < fechaNac.day)) {
        edad--;
      }
      return edad;
    } catch (e) {
      return null;
    }
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
    return 'User(id: $id, email: $email, nombre: $nombreCompleto, tipo: ${tipoUsuario.displayName})';
  }
}

// Enum para los proveedores de autenticación
enum AuthProvider {
  email('Email'),
  google('Google'),
  facebook('Facebook'),
  apple('Apple');

  const AuthProvider(this.displayName);
  final String displayName;
}

// Enum para el género del usuario
enum Genero {
  masculino('Masculino'),
  femenino('Femenino'),
  otro('Otro'),
  prefierNoDecir('Prefiero no decir');

  const Genero(this.displayName);
  final String displayName;
}

// Enum para el tipo de usuario
enum TipoUsuario {
  huesped('Huésped'),
  propietario('Propietario'),
  administrador('Administrador');

  const TipoUsuario(this.displayName);
  final String displayName;
}

// Clase para las preferencias del usuario
class PreferenciasUsuario {
  final bool notificacionesEmail;
  final bool notificacionesPush;
  final bool notificacionesReservas;
  final bool notificacionesOfertas;
  final String idioma;
  final String moneda;
  final bool modoOscuro;

  const PreferenciasUsuario({
    this.notificacionesEmail = true,
    this.notificacionesPush = true,
    this.notificacionesReservas = true,
    this.notificacionesOfertas = false,
    this.idioma = 'es',
    this.moneda = 'COP',
    this.modoOscuro = false,
  });

  factory PreferenciasUsuario.fromJson(Map<String, dynamic> json) {
    return PreferenciasUsuario(
      notificacionesEmail: json['notificacionesEmail'] as bool? ?? true,
      notificacionesPush: json['notificacionesPush'] as bool? ?? true,
      notificacionesReservas: json['notificacionesReservas'] as bool? ?? true,
      notificacionesOfertas: json['notificacionesOfertas'] as bool? ?? false,
      idioma: json['idioma'] as String? ?? 'es',
      moneda: json['moneda'] as String? ?? 'COP',
      modoOscuro: json['modoOscuro'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificacionesEmail': notificacionesEmail,
      'notificacionesPush': notificacionesPush,
      'notificacionesReservas': notificacionesReservas,
      'notificacionesOfertas': notificacionesOfertas,
      'idioma': idioma,
      'moneda': moneda,
      'modoOscuro': modoOscuro,
    };
  }

  PreferenciasUsuario copyWith({
    bool? notificacionesEmail,
    bool? notificacionesPush,
    bool? notificacionesReservas,
    bool? notificacionesOfertas,
    String? idioma,
    String? moneda,
    bool? modoOscuro,
  }) {
    return PreferenciasUsuario(
      notificacionesEmail: notificacionesEmail ?? this.notificacionesEmail,
      notificacionesPush: notificacionesPush ?? this.notificacionesPush,
      notificacionesReservas: notificacionesReservas ?? this.notificacionesReservas,
      notificacionesOfertas: notificacionesOfertas ?? this.notificacionesOfertas,
      idioma: idioma ?? this.idioma,
      moneda: moneda ?? this.moneda,
      modoOscuro: modoOscuro ?? this.modoOscuro,
    );
  }
}

// Clase para solicitud de registro
class RegisterRequest {
  final String email;
  final String password;
  final String confirmPassword;
  final String nombre;
  final String apellido;
  final String? telefono;
  final String? fechaNacimiento;
  final Genero? genero;
  final TipoUsuario tipoUsuario;
  final bool aceptaTerminos;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.nombre,
    required this.apellido,
    this.telefono,
    this.fechaNacimiento,
    this.genero,
    this.tipoUsuario = TipoUsuario.huesped,
    this.aceptaTerminos = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'fechaNacimiento': fechaNacimiento,
      'genero': genero?.name,
      'tipoUsuario': tipoUsuario.name,
      'aceptaTerminos': aceptaTerminos,
    };
  }

  // Validaciones
  bool get passwordsCoinciden => password == confirmPassword;
  bool get emailValido => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  bool get passwordValido => password.length >= 6;
  bool get nombreValido => nombre.trim().isNotEmpty;
  bool get apellidoValido => apellido.trim().isNotEmpty;
  bool get esValido => emailValido && 
                       passwordValido && 
                       passwordsCoinciden && 
                       nombreValido && 
                       apellidoValido && 
                       aceptaTerminos;

  List<String> get errores {
    final errores = <String>[];
    
    if (!emailValido) errores.add('Email no válido');
    if (!passwordValido) errores.add('La contraseña debe tener al menos 6 caracteres');
    if (!passwordsCoinciden) errores.add('Las contraseñas no coinciden');
    if (!nombreValido) errores.add('El nombre es requerido');
    if (!apellidoValido) errores.add('El apellido es requerido');
    if (!aceptaTerminos) errores.add('Debe aceptar los términos y condiciones');
    
    return errores;
  }
}

// Clase para actualizar perfil
class UpdateProfileRequest {
  final String? nombre;
  final String? apellido;
  final String? telefono;
  final String? fechaNacimiento;
  final Genero? genero;
  final String? photoUrl;
  final PreferenciasUsuario? preferencias;

  const UpdateProfileRequest({
    this.nombre,
    this.apellido,
    this.telefono,
    this.fechaNacimiento,
    this.genero,
    this.photoUrl,
    this.preferencias,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (nombre != null) json['nombre'] = nombre;
    if (apellido != null) json['apellido'] = apellido;
    if (telefono != null) json['telefono'] = telefono;
    if (fechaNacimiento != null) json['fechaNacimiento'] = fechaNacimiento;
    if (genero != null) json['genero'] = genero!.name;
    if (photoUrl != null) json['photoUrl'] = photoUrl;
    if (preferencias != null) json['preferencias'] = preferencias!.toJson();
    
    return json;
  }
}

// Clase para manejo de errores de autenticación
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, [this.code]);

  @override
  String toString() => 'AuthException: $message';
}

// Clase para el estado de autenticación
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
  bool get hasError => error != null;
}