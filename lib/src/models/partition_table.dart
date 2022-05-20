import 'package:disk_util/src/handlers/logger.dart';

///Basic representation of a Drive's Partition Table Scheme
enum PTableType {
  MS_DOS("ms-dos"),
  LOOP("loop"),
  GPT("gpt");

  ///String representation of the Partition Table Type
  final String type;

  const PTableType(this.type);

  String toString() => type.toUpperCase();

  ///[String] to [PTableType]
  ///
  /// ! Throws "Unkown Partition Table Type" if the partition table type is not one of the known types.
  factory PTableType.fromString(String str) {
    for (var pttype in PTableType.values) {
      if (pttype.type == str.toLowerCase()) {
        return pttype;
      }
    }
    logger.e("Unkown Partition Table Type: $str");
    throw "Unkown Partition Table Type: $str";
  }
}