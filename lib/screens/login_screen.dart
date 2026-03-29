import 'package:flutter/material.dart';
import '../../constants/design_system.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

/// 简化版登录页面（M3批次1）
/// 
/// 功能：
/// - 手机号+密码登录
/// - 跳转到注册
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validatePhone(String phone) {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
  }

  void _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    // 简单验证
    if (phone.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = '请输入手机号和密码');
      return;
    }
    if (!_validatePhone(phone)) {
      setState(() => _errorMessage = '请输入正确的手机号');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 调用登录 API
    final result = await AuthService().loginWithPassword(phone, password);

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (result.success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _errorMessage = result.errorMessage ?? '登录失败');
      }
    }
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.getBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: DesignSystem.getTextPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('登录', style: DesignSystem.getTitleMedium(context)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                
                // Logo
                Icon(Icons.terrain, size: 64, color: DesignSystem.getPrimary(context)),
                const SizedBox(height: 16),
                Text(
                  '山径APP',
                  textAlign: TextAlign.center,
                  style: DesignSystem.getTitleLarge(context),
                ),
                const SizedBox(height: 48),
                
                // 手机号输入
                _buildPhoneInput(),
                const SizedBox(height: 16),
                
                // 密码输入
                _buildPasswordInput(),
                
                // 错误提示
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: DesignSystem.getError(context), fontSize: 14),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // 登录按钮
                _buildLoginButton(),
                
                const SizedBox(height: 24),
                
                // 注册入口
                Center(
                  child: TextButton(
                    onPressed: _goToRegister,
                    child: Text(
                      '暂无账号？去注册',
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

  Widget _buildPhoneInput() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundSecondary(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.phone_android, size: 20, color: DesignSystem.getTextTertiary(context)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '请输入手机号',
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

  Widget _buildPasswordInput() {
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
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: '请输入密码',
                hintStyle: TextStyle(color: DesignSystem.getTextTertiary(context)),
                border: InputBorder.none,
              ),
              style: DesignSystem.getBodyLarge(context),
            ),
          ),
          IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: DesignSystem.getTextTertiary(context),
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
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
            : const Text('登录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
