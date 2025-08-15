import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_strings.dart' show AppStrings;
  import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/auth/widgets/primary_button.dart';

import '../../../core/config/app_colors.dart';
import '../controllers/verify_email_controller.dart';
import '../widgets/custom_pin_code_field.dart';
import '../widgets/custom_text.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late ReceivePort _receivePort;
  late SendPort _sendPort;
  int _start = 60; // Timer starting value (seconds)
  bool _isButtonDisabled = true;
  late Isolate _isolate;
  late TextEditingController _forgotPasswordTEController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  VerifyEmailController verifyEmailController = Get.find<VerifyEmailController>(); /// controller initialization

  @override
  void initState() {
    super.initState();
    _forgotPasswordTEController = TextEditingController();
    _startTimer();
  }

  @override
  void dispose() {
    _receivePort.close();
    _isolate.kill();
    super.dispose();
  }

  // Start the countdown timer using Isolate
  void _startTimer() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_startCountdown, _receivePort.sendPort);

    _receivePort.listen((count) {
      setState(() {
        _start = count;
        if (_start == 0) {
          _isButtonDisabled = false;
        }
      });
    });
  }

  // Function that runs in the isolate
  static void _startCountdown(SendPort sendPort) {
    int _start = 60;
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _start--;
      sendPort.send(_start);
      if (_start == 0) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.fromLTRB(32, 108, 32, 0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Center(
                    child: CustomRichText(firstLabel: 'Verify', secondLabel: 'Email'),
                  ),

                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      AppStrings.pleaseCheckYourEmailAndEnterTheCode,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.blackColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const CustomPinCodeTextField(),
                  const SizedBox(height: 32),
                  // Timer Text
                  Center(
                    child: Row(
                      spacing: 5,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.access_time_outlined),
                        Text(
                          _formatTime(_start),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  PrimaryButton(
                    buttonText: AppStrings.confirm,
                    // Text that will appear on the button
                    onPressed: () {
                      Get.toNamed(AppRoutes.resetPasswordRoute);
                    },
                  ),
                  const SizedBox(height: 32),
                  Visibility(
                    visible: !_isButtonDisabled,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          AppStrings.didNotReceiveCode,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            _resetTimer(); // Reset and start the timer again
                          },
                          child: Text(
                            AppStrings.resendIt,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Format the time in MM:SS
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Reset the timer to initial state
  void _resetTimer() {
    setState(() {
      _start = 60;
      _isButtonDisabled = true;
    });
    _startTimer();
  }
}
