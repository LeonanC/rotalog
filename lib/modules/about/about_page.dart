import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:rotalog/modules/about/about_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends GetView<AboutController> {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: controller.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(RemixIcons.arrow_left_s_line, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'ab_titulo'.tr,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        final isChecking = controller.isCheckingForUpdate.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: controller.primaryAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: controller.primaryAccent.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    RemixIcons.truck_fill,
                    size: 60,
                    color: controller.primaryAccent,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "lg_titulo".tr,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              Text(
                "ab_version".trParams({'version': controller.appVersion.value}),
                style: TextStyle(
                  fontFamily: 'ShareTechMono',
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "ab_descrition".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              _buildActionButton(
                label: 'ab_check_for_updates'.tr,
                icon: isChecking ? null : RemixIcons.download_line,
                color: Colors.orange,
                isLoading: isChecking,
                onPressed: isChecking ? null : controller.checkForUpdate,
              ),
              _buildActionButton(
                label: "ab_dev".trParams({'name': 'Leonan C.'}),
                icon: RemixIcons.code_s_slash_line,
                color: Colors.greenAccent,
                onPressed: () => _launchURL('https://github.com/LeonanC'),
              ),
              _buildActionButton(
                label: "ab_repo".tr,
                icon: RemixIcons.github_fill,
                color: Colors.blueAccent,
                onPressed: () =>
                    _launchURL('https://github.com/LeonanC/rotalog'),
              ),
              _buildActionButton(
                label: "ab_lienca".tr,
                icon: RemixIcons.shield_check_line,
                color: Colors.tealAccent,
                onPressed: () => _launchURL(
                  'https://github.com/LeonanC/rotalog/blob/main/LICENSE',
                ),
              ),
              const SizedBox(height: 60),
              Opacity(
                opacity: 0.3,
                child: Column(
                  children: [
                    Text(
                      "ab_powered_by".tr,
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Grupo Amigos Transporte",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w900,
                        color: controller.primaryAccent,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionButton({
    required String label,
    IconData? icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }
}
