export 'models/disk.dart';
export 'models/volume.dart';
export 'models/fs_type.dart';
export 'models/partition_table.dart';

import 'dart:io';

import 'package:disk_util/disk_util.dart';
import 'package:disk_util/src/handlers/logger.dart';

import 'linux/query_system.dart' as linux;
import 'macos/query_system.dart' as macos;
import 'windows/query_system.dart' as windows;

class DiskUtil {
  ///Query the Disks from the OS
  ///Returns a list of found drives
  Future<List<Disk>> get_disks() async {
    if (Platform.isLinux) {
      return await linux.get_disks();
    } else if (Platform.isMacOS) {
      return await macos.get_disks();
    } else if (Platform.isWindows) {
      return await windows.get_disks();
    } else {
      logger.e("Unsopported Platform: ${Platform.operatingSystem}");
      throw "Unsopported System: ${Platform.operatingSystem}";
    }
  }

  static String formatSize(int size) {
    for (var entry in _sizeIncrements.entries) {
        var result = size / entry.key;
        if(result >= 1) {
          return "${result.toStringAsFixed(2)} ${entry.value}";
        }
    }
    return "$size B";
  }
}

Map<int, String> _sizeIncrements = {
  1000000000000000000: "EB",
  1000000000000000: "PB",
  1000000000000: "TB",
  1000000000: "GB",
  1000000: "MB",
  1000: "KB",
};
