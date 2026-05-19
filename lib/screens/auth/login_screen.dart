import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Đăng nhập thất bại'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: AppTheme.radiusFull),
                  child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.onSurface),
                ),
              ),
              const SizedBox(height: 36),
              // Title
              Text('Chào mừng\ntrở lại! 👋', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, height: 1.2)),
              const SizedBox(height: 8),
              Text('Đăng nhập để tiếp tục hành trình', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.outline)),
              const SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(children: [
                  // Email
                  _buildField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'your@email.com',
                    icon: Icons.email_outlined,
                    keyboard: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Vui lòng nhập email';
                      if (!v.contains('@')) return 'Email không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Password
                  _buildField(
                    controller: _passCtrl,
                    label: 'Mật khẩu',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    obscure: _obscurePass,
                    suffix: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppTheme.outline, size: 20),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                      if (v.length < 6) return 'Mật khẩu ít nhất 6 ký tự';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Forgot
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Quên mật khẩu?', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg),
                        elevation: 0,
                      ),
                      child: auth.isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Đăng nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('hoặc', style: TextStyle(color: AppTheme.outline, fontSize: 13)),
                    ),
                    const Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 24),
                  // Social login (mock)
                  _buildSocialButton(
                    icon: '🌐',
                    label: 'Tiếp tục với Google',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildSocialButton(
                    icon: '📱',
                    label: 'Tiếp tục với số điện thoại',
                    onTap: () {},
                  ),
                ]),
              ),
              const SizedBox(height: 40),
              // Register link
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Chưa có tài khoản? ', style: TextStyle(color: AppTheme.outline)),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                  child: const Text('Đăng ký ngay', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.onSurface)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.outline.withValues(alpha: 0.6), fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: AppTheme.outline),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppTheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: AppTheme.radiusLg, borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: AppTheme.radiusLg, borderSide: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.3))),
            focusedBorder: OutlineInputBorder(borderRadius: AppTheme.radiusLg, borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: AppTheme.radiusLg, borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: AppTheme.radiusLg, borderSide: const BorderSide(color: Colors.red, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({required String icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusLg,
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
