import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:rotalog/data/controllers/authController.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(RemixIcons.truck_fill, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 10),
                Text(
                  "lg_titulo".tr,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 40),
                Obx(
                  () => Column(
                    children: [
                      if (!controller.isLogin.value) ...[
                        _buildTextField(
                          label: "lg_nome_completo".tr,
                          icon: RemixIcons.user_3_line,
                          controller: controller.nomeController,
                        ),
                        _buildTextField(
                          label: "lg_placa".tr,
                          icon: RemixIcons.steering_2_line,
                          controller: controller.placaController,
                        ),
                        _buildTextField(
                          label: "lg_modelo".tr,
                          icon: RemixIcons.truck_line,
                          controller: controller.modeloCaminhaoController,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: "lg_cnh".tr,
                                icon: RemixIcons.id_card_line,
                                controller: controller.cnhNumeroController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                label: "lg_validade".tr,
                                icon: RemixIcons.calendar_check_line,
                                controller: controller.cnhValidadeController,
                                readOnly: true,
                                onTap: () =>
                                    controller.escolherDataValidade(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                      _buildTextField(
                        label: "lg_email".tr,
                        icon: RemixIcons.mail_line,
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildTextField(
                        label: "lg_senha".tr,
                        icon: RemixIcons.lock_password_line,
                        controller: controller.senhaController,
                        isPassword: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.realizarAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            controller.isLogin.value
                                ? "lg_entrar".tr
                                : "lg_cadastrar".tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: controller.toggleAuthMode,
                  child: Obx(
                    () => Text(
                      controller.isLogin.value
                          ? "lg_nao_tem_conta".tr
                          : "lg_ja_tem_conta".tr,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Montserrat',
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
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    final authController = Get.find<AuthController>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? authController.obscureText.value : false,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: const TextStyle(color: Colors.white),
        validator: (value) => value!.isEmpty ? "lg_erro_campo".tr : null,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    authController.obscureText.value
                        ? RemixIcons.eye_off_line
                        : RemixIcons.eye_line,
                    color: Colors.white30,
                  ),
                  onPressed: authController.toggleObscure,
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
