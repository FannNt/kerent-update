import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F1F),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 40),
                  _buildWelcomeText(),
                  SizedBox(height: 20),
                  _buildSocialButtons(),
                  SizedBox(height: 20),
                  _buildDivider(),
                  SizedBox(height: 20),
                  _buildInputFields(),
                  SizedBox(height: 30),
                  _buildRegisterButton(),
                ],
              ),
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
          'Selamat Datang',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Silakan masukkan detail untuk masuk.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Image.asset('assets/images/google-icon2.png', height: 20),
            label: Text(''),
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
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.phone_android_sharp),
            label: Text(''),
            onPressed: controller.signInWithPhone,
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

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildInputField(
          'Username',
          controller.username,
          (val) => controller.username.value = val,
        ),
        SizedBox(height: 15),
        _buildInputField(
          'Phone Number',
          controller.phoneNumber,
          (val) => controller.phoneNumber.value = val,
          isPhoneNumber: true,
        ),
        SizedBox(height: 15),
        _buildInputField(
          'Email',
          controller.email,
          (val) => controller.email.value = val,
          isEmail: true,
        ),
        SizedBox(height: 15),
        _buildInputField(
          'Password',
          controller.password,
          (val) => controller.password.value = val,
          isPassword: true,
        ),
        SizedBox(height: 15),
        _buildInputField(
          'Confirm Password',
          controller.confirmPassword,
          (val) => controller.confirmPassword.value = val,
          isPassword: true,
          isConfirmPassword: true,
        ),
      ],
    );
  }

  Widget _buildInputField(String label, RxString value, Function(String) onChanged, {bool isPassword = false, bool isConfirmPassword = false, bool isEmail = false, bool isPhoneNumber = false}) {
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
    keyboardType: isPhoneNumber ? TextInputType.phone : (isEmail ? TextInputType.emailAddress : TextInputType.text),
    validator: (val) => controller.validateField(val, isPassword, isConfirmPassword, isEmail),
    onChanged: (val) {
      onChanged(val);
      value.value = val; // Update the Rx value directly
    },
    // Use Obx only for the text
    controller: TextEditingController(text: value.value),
  );
}



  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.register,
        child: Text('Register'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.orange,
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}