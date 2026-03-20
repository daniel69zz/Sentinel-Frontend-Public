import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../services/auth_identity_mapper.dart';
import '../services/password_recovery_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordRecoveryService = PasswordRecoveryService();
  final _formKey = GlobalKey<FormState>();

  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  bool _codeRequested = false;
  String? _debugCode;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSendingCode = true);
    final result = await _passwordRecoveryService.sendVerificationCode(
      _emailController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSendingCode = false;
      _codeRequested = result.success;
      _debugCode = result.debugCode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? AppTheme.success : AppTheme.error,
      ),
    );
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isVerifyingCode = true);
    final result = await _passwordRecoveryService.verifyCode(
      email: _emailController.text,
      code: _codeController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() => _isVerifyingCode = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? AppTheme.success : AppTheme.error,
      ),
    );

    if (result.success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                ],
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.07),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppTheme.textPrimary,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Recuperar acceso',
                      style: AppTheme.headlineLarge.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingresa tu Gmail y te enviaremos un codigo de verificacion.',
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: _codeRequested
                          ? TextInputAction.next
                          : TextInputAction.done,
                      style: AppTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Correo Gmail',
                        prefixIcon: Icon(
                          Icons.alternate_email_rounded,
                          color: AppTheme.textSecondary,
                        ),
                        hintText: 'nombre@gmail.com',
                      ),
                      validator: (value) {
                        if (!AuthIdentityMapper.isValidEmail(value ?? '')) {
                          return 'Ingresa un correo Gmail valido';
                        }
                        return null;
                      },
                    ),
                    if (_codeRequested) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        style: AppTheme.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'Codigo de verificacion',
                          prefixIcon: Icon(
                            Icons.pin_outlined,
                            color: AppTheme.textSecondary,
                          ),
                          hintText: '123456',
                        ),
                        validator: (value) {
                          if (!_codeRequested) {
                            return null;
                          }

                          if ((value ?? '').trim().length != 6) {
                            return 'Ingresa el codigo de 6 digitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Modo demo', style: AppTheme.titleLarge),
                            const SizedBox(height: 6),
                            Text(
                              'Mientras conectamos el envio real por correo, el codigo se muestra aqui para que puedas probar el flujo.',
                              style: AppTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            SelectableText(
                              _debugCode ?? '------',
                              style: AppTheme.headlineMedium.copyWith(
                                color: AppTheme.primaryLight,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    CustomButton(
                      text: _codeRequested
                          ? 'Validar codigo'
                          : 'Enviar codigo de verificacion',
                      onPressed: _codeRequested ? _verifyCode : _sendCode,
                      isLoading: _codeRequested
                          ? _isVerifyingCode
                          : _isSendingCode,
                    ),
                    if (_codeRequested) ...[
                      const SizedBox(height: 14),
                      CustomButton(
                        text: 'Enviar otro codigo',
                        variant: ButtonVariant.outline,
                        onPressed: _sendCode,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Usa el mismo Gmail con el que registraste tu cuenta.',
                      style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
