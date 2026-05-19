import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  int _currentStep = 0; // 0: info, 1: password

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý với điều khoản dịch vụ'), backgroundColor: Colors.orange),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/main');
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
              Text('Tạo tài khoản\nmới 🚗', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, height: 1.2)),
              const SizedBox(height: 8),
              Text('Tham gia cộng đồng đi xe chung', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.outline)),
              const SizedBox(height: 36),

              // Progress indicator
              _buildProgressBar(),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              if (_currentStep == 0)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _goToStep2,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg),
                      elevation: 0,
                    ),
                    child: const Text('Tiếp theo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                )
              else
                Column(children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg),
                        elevation: 0,
                      ),
                      child: auth.isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Đăng ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() => _currentStep = 0),
                    child: const Text('← Quay lại', style: TextStyle(color: AppTheme.outline)),
                  ),
                ]),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Đã có tài khoản? ', style: TextStyle(color: AppTheme.outline)),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Đăng nhập', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(children: [
      Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: AppTheme.radiusFull))),
      const SizedBox(width: 8),
      Expanded(child: Container(height: 4, decoration: BoxDecoration(color: _currentStep >= 1 ? AppTheme.primary : AppTheme.surfaceContainerLow, borderRadius: AppTheme.radiusFull))),
    ]);
  }

  Widget _buildStep1() {
    return Column(key: const ValueKey(0), children: [
      _buildField(controller: _nameCtrl, label: 'Họ và tên', hint: 'Nguyễn Văn A', icon: Icons.person_outline, validator: (v) => v == null || v.length < 2 ? 'Vui lòng nhập họ tên' : null),
      const SizedBox(height: 16),
      _buildField(controller: _emailCtrl, label: 'Email', hint: 'your@email.com', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress, validator: (v) {
        if (v == null || v.isEmpty) return 'Vui lòng nhập email';
        if (!v.contains('@')) return 'Email không hợp lệ';
        return null;
      }),
      const SizedBox(height: 16),
      _buildField(controller: _phoneCtrl, label: 'Số điện thoại', hint: '0901234567', icon: Icons.phone_outlined, keyboard: TextInputType.phone, validator: (v) {
        if (v == null || v.length < 10) return 'Số điện thoại không hợp lệ';
        return null;
      }),
    ]);
  }

  Widget _buildStep2() {
    return Column(key: const ValueKey(1), children: [
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
          if (v == null || v.length < 6) return 'Mật khẩu ít nhất 6 ký tự';
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildField(
        controller: _confirmCtrl,
        label: 'Xác nhận mật khẩu',
        hint: '••••••••',
        icon: Icons.lock_outline,
        obscure: _obscureConfirm,
        suffix: IconButton(
          icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppTheme.outline, size: 20),
          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
        validator: (v) {
          if (v != _passCtrl.text) return 'Mật khẩu không khớp';
          return null;
        },
      ),
      const SizedBox(height: 20),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _agreeTerms,
            onChanged: (v) => setState(() => _agreeTerms = v ?? false),
            activeColor: AppTheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: AppTheme.onSurface, fontSize: 13),
                  children: [
                    const TextSpan(text: 'Tôi đồng ý với '),
                    TextSpan(text: 'Điều khoản dịch vụ', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                    const TextSpan(text: ' và '),
                    TextSpan(text: 'Chính sách bảo mật', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  void _goToStep2() {
    if (_nameCtrl.text.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập họ tên'), backgroundColor: Colors.orange));
      return;
    }
    if (!_emailCtrl.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email không hợp lệ'), backgroundColor: Colors.orange));
      return;
    }
    if (_phoneCtrl.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số điện thoại không hợp lệ'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _currentStep = 1);
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
}
