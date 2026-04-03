import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:rotalog/data/controllers/lookupController.dart';
import 'package:rotalog/modules/registro/registro_controller.dart';

class RegistroPage extends GetView<RegistroController> {
  const RegistroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "reg_titulo".tr,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(RemixIcons.arrow_left_line),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              _buildTextField(
                label: "reg_origem".tr,
                controller: controller.origemController,
                icon: RemixIcons.map_pin_2_line,
              ),
              _buildTextField(
                label: "reg_destino".tr,
                controller: controller.destinoController,
                icon: RemixIcons.flag_line,
              ),
              _buildTextField(
                label: "reg_carga".tr,
                controller: controller.cargaController,
                icon: RemixIcons.box_3_line,
              ),
              _buildTextField(
                label: "reg_receita".tr,
                controller: controller.receitaController,
                icon: RemixIcons.money_dollar_circle_line,
                keyboardType: TextInputType.number,
                isNumberic: true,
              ),
              _buildCategoriaSelector(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: "reg_peso".tr,
                      controller: controller.pesoController,
                      icon: RemixIcons.scales_line,
                      keyboardType: TextInputType.number,
                      isNumberic: true,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      label: "reg_distancia".tr,
                      controller: controller.distanciaController,
                      icon: RemixIcons.route_line,
                      keyboardType: TextInputType.number,
                      isNumberic: true,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 40),
              _buildTipoRodoviaSelector(),
              const SizedBox(height: 30),
              _buildRodoviasInput(),

              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : () => controller.salvarTrabalho(),
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
                "reg_btn_salvar".tr,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool isNumberic = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontFamily: 'Montserrat', color: Colors.white),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "reg_erro_obrigatorio".tr;
          }
          if (isNumberic) {
            final n = num.tryParse(value.replaceAll(',', '.'));
            if (n == null) return "reg_erro_numero".tr;
            if (n <= 0) return "reg_erro_zero".tr;
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF1E2938),
          errorStyle: const TextStyle(
            color: Color(0xFFFB7185),
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xFFFB7185), width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriaSelector() {
    final lookupController = Get.find<Lookupcontroller>();

    return Obx(() {
      if (lookupController.categoriaEntries.isEmpty) {
        return const LinearProgressIndicator();
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: lookupController.categoriaEntries.map((doc) {
          final String nome = doc.nome;

          return Obx(() {
            final isSelected = controller.tipoCategoriaSelecionada.contains(
              nome,
            );
            return FilterChip(
              label: Text(nome),
              labelStyle: TextStyle(
                fontFamily: 'Montserrat',
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              selected: isSelected,
              selectedColor: Colors.blueAccent,
              checkmarkColor: Colors.white,
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onSelected: (_) => controller.alternarCategoria(nome),
            );
          });
        }).toList(),
      );
    });
  }

  Widget _buildTipoRodoviaSelector() {
    final lookupController = Get.find<Lookupcontroller>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "reg_titulo_tipos".tr,
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.blueAccent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (lookupController.tiposEntries.isEmpty) {
            return const LinearProgressIndicator();
          }

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: lookupController.tiposEntries.map((doc) {
              final String nome = doc.nome;

              return Obx(() {
                final isSelected = controller.tipoRodoviaSelecionada.contains(
                  nome,
                );
                return FilterChip(
                  label: Text(nome),
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  selected: isSelected,
                  selectedColor: Colors.blueAccent,
                  checkmarkColor: Colors.white,
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onSelected: (_) => controller.alternarTipoRodovia(nome),
                );
              });
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildRodoviasInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "reg_titulo_rodovias".tr,
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.rodoviasInputController,
                decoration: InputDecoration(
                  hintText: "reg_hint_rodovias".tr,
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),
            ),
            IconButton(
              onPressed: () => controller.adicionarRodovia(),
              icon: Icon(RemixIcons.add_circle_fill, color: Colors.blueAccent),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(
          () => Wrap(
            spacing: 8,
            children: controller.rodoviasSelecionadas
                .map(
                  (r) => Chip(
                    label: Text(
                      r['nome'],
                      style: TextStyle(fontFamily: 'ShareTechMono'),
                    ),
                    onDeleted: () => controller.removerRodovia(r['nome']),

                    deleteIconColor: Colors.redAccent,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
