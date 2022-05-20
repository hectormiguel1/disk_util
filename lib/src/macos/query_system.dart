import 'dart:io';
import 'package:disk_util/disk_util.dart';
import 'package:disk_util/src/handlers/logger.dart';
import 'package:plist_parser/plist_parser.dart';

final int _sucess = 0;

Future<List<Disk>> get_disks() async {
  List<Disk> disks = [];

  var apfs_data = (await _query_apfs())[""];

  return disks;
}

Future<List<Disk>> _get_disks() async {
  List<Disk> disks = [];
  var _os_disks = await _get_os_disks();
  _os_disks.forEach((element) async {
    var disk_props = await _get_disk_info(element);
    if (disk_props["WholeDisk"]) {
      disks.add(
        Disk(
          fsHandler: Directory(disk_props["DeviceNode"]),
          size: disk_props["Size"],
          pTableType: PTableType.GPT,
          isSystemDrive:
              _os_disks.length > 1 ? disk_props["SystemImage"] : true,
          volumes: [],
        ),
      );
      logger.i(disks);
    } else {
      try {
        disks.forEach((element) {
          if (element.fsHandler.path ==
              "/dev/${disk_props["ParentWholeDisk"]}") {
            logger.i("Found Parent Disk");
            element.volumes.add(Volume(
                fsHandler: Directory(disk_props["DeviceNode"]),
                mountPoint: (disk_props["MountPoint"] as String).isEmpty
                    ? null
                    : Directory(disk_props["MountPoint"]),
                isMounted: (disk_props["MountPoint"] as String).isNotEmpty,
                fsSize: disk_props["Size"],
                label: disk_props["VolumeName"],
                sizeAvail: disk_props["FreeSpace"],
                sizeUsed: disk_props['Size'] - disk_props['FreeSpace'],
                fsType: FSType.fromString(disk_props["FileSystemType"])));
          }
        });
      } catch (e) {
        logger.e("No Parent Disk: ${disk_props["ParentWholeDisk"]}, error: $e");
      }
    }
  });
  return disks;
}

Future<List<dynamic>> _get_os_disks() async {
  var process = await Process.run("diskutil", ["list", "-plist"]);
  if (process.exitCode == _sucess) {
    return PlistParser().parse(process.stdout as String)["AllDisks"] as List;
  } else {
    logger.e("OS Call exited with non zero exit code: ${process.exitCode}");
    throw "Process Exit Non-Zero";
  }
}

Future<Map<dynamic, dynamic>> _get_disk_info(String disk) async {
  var process = await Process.run("diskutil", ["info", "-plist", "/dev/$disk"]);
  if (process.exitCode == _sucess) {
    return PlistParser().parse(process.stdout as String);
  } else {
    logger
        .e("DiskUtil info exited with Non-Zero exit Code: ${process.exitCode}");
    throw "Process Exit Non-Zero";
  }
}

Future<Map<dynamic, dynamic>> _query_apfs() async {
  var process = await Process.run("diskutil", ["apfs", "list", "-plist"]);
  if (process.exitCode == _sucess) {
    return PlistParser().parseXml(process.stdout as String);
  } else {
    logger.e("DiskUtil Non-Zero Exit Code: ${process.exitCode}");
    throw "Process exit Non-Zero";
  }
}
