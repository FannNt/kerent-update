import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F1F),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 40),
                _buildWelcomeText(),
                SizedBox(height: 20),
                _buildInputFields(),
                SizedBox(height: 20),
                _buildForgotPassword(),
                SizedBox(height: 30),
                _buildLoginButton(),
                SizedBox(height: 20),
                _buildDivider(),
                SizedBox(height: 20),
                _buildSocialButtons(),
                SizedBox(height: 20),
                _buildRegisterPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          color: Colors.white,
        ),
        SizedBox(width: 10),
        Text(
          'Kerent',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Please sign in to continue.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildInputField('Email', controller.email, (val) => controller.email.value = val, isEmail: true),
        SizedBox(height: 15),
        _buildInputField('Password', controller.password, (val) => controller.password.value = val, isPassword: true),
      ],
    );
  }

  Widget _buildInputField(String label, RxString value, Function(String) onChanged, {bool isPassword = false, bool isEmail = false}) {
    return TextFormField(
      obscureText: isPassword,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      onChanged: (val) {
        onChanged(val);
        value.value = val;
      },
      controller: TextEditingController(text: value.value),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: controller.resetPassword,
        child: Text(
          'Forgot Password?',
          style: TextStyle(color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.login,
        child: Text('Login'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.orange,
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('OR', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Image.asset('assets/images/google-icon2.png', height: 20),
            label: Text('Google'),
            onPressed: controller.signInWithGoogle,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFF2A2A2A),
              padding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
        TextButton(
          onPressed: () => Get.toNamed('/register'),
          child: Text('Register', style: TextStyle(color: Colors.orange)),
        ),
      ],
    );
  }
}