import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginViewModel _viewModel = LoginViewModel();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Iniciar animaciones
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    // Mostrar siempre botón de retroceso y redirigir a Welcome

    return WillPopScope(
      onWillPop: () async {
        // Redirigir siempre a la vista de Welcome y evitar pop por defecto
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1565C0), // Azul suave
                Color(0xFF0277BD), // Azul medio
                Color(0xFFF8F9FA), // Blanco suave en la parte inferior
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header con botón de retroceso
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32.0 : 20.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      children: [
                        // Botón de regreso siempre visible: va a Welcome
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/',
                              (Route<dynamic> route) => false,
                            );
                          },
                          splashRadius: 22,
                        ),
                        const SizedBox(width: 16),
                        // Título
                        Text(
                          '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 26 : 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Contenido principal
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 80.0 : 24.0,
                        vertical: 40.0,
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo con acento sutil amarillo
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Icon(
                                      Icons.inventory_2_rounded,
                                      size: isTablet ? 80 : 64,
                                      color: const Color(0xFF1565C0),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF8E1),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFFFFF176),
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.verified_rounded,
                                          size: isTablet ? 20 : 16,
                                          color: const Color(0xFFF9A825),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              Text(
                                'Objetos Perdidos UPT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 32 : 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  fontFamily: 'SF Pro Display',
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Accede a tu cuenta',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 48),

                              // Card de formulario
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: isTablet ? 400 : double.infinity,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    isTablet ? 40.0 : 32.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(
                                          fontSize: isTablet ? 24 : 22,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2C3E50),
                                          letterSpacing: 0.3,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      const SizedBox(height: 32),

                                      // Campo de email/DNI
                                      _buildTextField(
                                        controller: emailController,
                                        label: 'Correo institucional o DNI',
                                        icon: Icons.person_rounded,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),

                                      const SizedBox(height: 20),

                                      // Campo de contraseña
                                      _buildTextField(
                                        controller: passwordController,
                                        label: 'Contraseña',
                                        icon: Icons.lock_rounded,
                                        isPassword: true,
                                        obscureText: _obscurePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_rounded
                                                : Icons.visibility_off_rounded,
                                            color: const Color(0xFF1565C0),
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // Botón de iniciar sesión
                                      _isLoading
                                          ? Container(
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1565C0),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF1565C0),
                                                    Color(0xFF0277BD),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF1565C0,
                                                    ).withOpacity(0.3),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14,
                                                        ),
                                                  ),
                                                  minimumSize: const Size(
                                                    double.infinity,
                                                    48,
                                                  ),
                                                ),
                                                onPressed: _handleLogin,
                                                child: Text(
                                                  'Iniciar Sesión',
                                                  style: TextStyle(
                                                    fontSize: isTablet
                                                        ? 16
                                                        : 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ),

                                      const SizedBox(height: 20),

                                      // Enlace de recuperar contraseña
                                      TextButton(
                                        onPressed: () async {
                                          HapticFeedback.selectionClick();
                                          final email = emailController.text
                                              .trim();
                                          if (email.isEmpty) {
                                            _showErrorDialog(
                                              'Ingresa tu correo para enviarte el enlace de restablecimiento.',
                                            );
                                            return;
                                          }
                                          setState(() => _isLoading = true);
                                          final err = await _viewModel
                                              .sendPasswordReset(email);
                                          if (!mounted) return;
                                          setState(() => _isLoading = false);
                                          if (err == null) {
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                title: const Text(
                                                  'Revisa tu correo',
                                                ),
                                                content: Text(
                                                  'Te enviamos un enlace para restablecer tu contraseña a:\n$email',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text(
                                                      'Entendido',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            _showErrorDialog(err);
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                        child: Text(
                                          '¿Olvidaste tu contraseña?',
                                          style: TextStyle(
                                            color: const Color(0xFF1565C0),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: Color(0xFF2C3E50)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF6C757D),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(icon, color: const Color(0xFF1565C0), size: 20),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _showErrorDialog('Por favor, completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.selectionClick();

    try {
      final error = await _viewModel.signIn(
        emailController.text.trim(),
        passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (error == null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showErrorDialog(error);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Error inesperado. Inténtalo de nuevo.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red[600], size: 24),
            const SizedBox(width: 12),
            const Text(
              'Error de autenticación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Color(0xFF5A6C7D)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
