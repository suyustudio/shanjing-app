import 'package:flutter/material.dart';
import '../../constants/design_system.dart';
import '../../services/auth_service.dart';

/// 简化版注册页面（M3批次1）
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  bool _validatePhone(String phone) {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
  }

  void _handleRegister() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final nickname = _nicknameController.text.trim();

    // 简单验证
    if (phone.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = '请输入手机号和密码');
      return;
    }
    if (!_validatePhone(phone)) {
      setState(() => _errorMessage = '请输入正确的手机号');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = '密码至少6位');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = '两次密码不一致');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 调用注册 API
    final result = await AuthService().registerWithPassword(
      phone, 
      password,
      nickname: nickname.isNotEmpty ? nickname : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (result.success) {
        // 注册成功，返回登录页
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('注册成功，请登录')),
        );
      } else {
        setState(() => _errorMessage = result.errorMessage ?? '注册失败');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.getBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: DesignSystem.getTextPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('注册', style: DesignSystem.getTitleMedium(context)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                // 手机号
                _buildInputField(
                  controller: _phoneController,
                  hint: '请输入手机号',
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                
                // 昵称（可选）
                _buildInputField(
                  controller: _nicknameController,
                  hint: '昵称（可选）',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                
                // 密码
                _buildPasswordField(
                  controller: _passwordController,
                  hint: '请输入密码（至少6位）',
                  obscureText: _obscurePassword,
                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 16),
                
                // 确认密码
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  hint: '请再次输入密码',
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                
                // 错误提示
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: DesignSystem.getError(context), fontSize: 14),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // 注册按钮
                _buildRegisterButton(),
                
                const SizedBox(height: 24),
                
                // 返回登录
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      '已有账号？去登录',
                      style: TextStyle(color: DesignSystem.getPrimary(context)),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundSecondary(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, size: 20, color: DesignSystem.getTextTertiary(context)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: DesignSystem.getTextTertiary(context)),
                border: InputBorder.none,
              ),
              style: DesignSystem.getBodyLarge(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundSecondary(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.lock_outline, size: 20, color: DesignSystem.getTextTertiary(context)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: DesignSystem.getTextTertiary(context)),
                border: InputBorder.none,
              ),
              style: DesignSystem.getBodyLarge(context),
            ),
          ),
          IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: DesignSystem.getTextTertiary(context),
            ),
            onPressed: onToggleVisibility,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignSystem.getPrimary(context),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('注册', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
