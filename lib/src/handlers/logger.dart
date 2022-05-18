
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    lineLength: 80,
    stackTraceBeginIndex: 0, 
    methodCount: 1
  )
);