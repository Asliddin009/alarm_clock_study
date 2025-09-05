// ignore_for_file: avoid_single_cascade_in_expression_statements
//, strict_raw_type

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

abstract class AppSnackBar {
  static void showSnackBarWithError(BuildContext context, String error) {
    BaseSnackBar.show(
      context,
      error,
      icon: const Icon(
        Icons.error_rounded,
        size: 33,
        color: Colors.red,
      ),
    );
  }

  static void showSnackBarWithMessage(BuildContext context, String message) {
    BaseSnackBar.show(
      context,
      message,
      icon: Icon(
        Icons.warning_rounded,
        size: 33,
        color: Colors.yellow.shade400,
      ),
    );
  }

  static void showSnackBarSuccesful(BuildContext context, String message) {
    BaseSnackBar.show(
      context,
      message,
      icon: const Icon(
        Icons.check_rounded,
        size: 33,
        color: Colors.green,
      ),
    );
  }

  static void clearSnackBars(BuildContext context) {
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
  }
}

bool flagShowSnackBar = true;

abstract class BaseSnackBar {
  // ignore: strict_raw_type
  static Future show(
    BuildContext context,
    String title, {
    Icon? icon,
  }) async {
    if (flagShowSnackBar) {
      flagShowSnackBar = false;
      // ignore: inference_failure_on_instance_creation
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: title,
        messageColor: Colors.white,
        icon: Padding(
          padding: const EdgeInsets.all(10),
          child: icon,
        ),
        margin: const EdgeInsets.all(20),
        maxWidth: 500,
        padding: const EdgeInsets.only(left: 40, right: 20),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        duration: const Duration(seconds: 2),
        // ignore: unawaited_futures
      )..show(context).then((value) {
          flagShowSnackBar = true;
        });
    }
  }
}
