import 'dart:io';


import 'package:logger/logger.dart' as logger;
import 'package:mate_app/helper/path.dart';
import 'package:mate_app/helper/platform.dart';

class Logger {
  static final logger.Logger instance = logger.Logger(
    printer: logger.PrettyPrinter(
      lineLength: 120,
      printTime: true,
      colors: false,
      noBoxingByDefault: true,
    ),
    output: logger.MultiOutput(
      [
        logger.ConsoleOutput(),
        if (!PlatformTool.isWeb())
          logger.FileOutput(
            file: File(PathHelper().getLogfilePath),
            overrideExisting: true,
          ),
      ],
    ),
  );
}