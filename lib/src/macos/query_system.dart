import 'dart:io';
import 'package:disk_util/disk_util.dart';
import 'package:disk_util/src/handlers/logger.dart';
import 'package:executor/executor.dart';
import 'package:plist_parser/plist_parser.dart';

final int _sucess = 0;

Future<List<Disk>> get_disks() async {
  List<Disk> disks = [];
  var apfs_data = {};
  var executor = Executor(concurrency: 5);

  var found_nodes = await _query_drives();
  executor
      .scheduleTask<Map<dynamic, dynamic>>(() async => await _query_apfs())
      .then((value) => apfs_data = value);

  for (var diskID in found_nodes["Disks"]) {
    executor.scheduleTask<Disk>(() async {
      var drive_info = await _get_data(diskID);
      return Disk(
          volumes: [],
          fsHandler: Directory(drive_info["DeviceNode"]),
          size: drive_info["Size"],
          pTableType: (drive_info["Content"] as String).contains("GUID")
              ? PTableType.GPT
              : PTableType.fromString(drive_info["Content"]));
    }).then((disk) => disks.add(disk));
  }
  await executor.join(withWaiting: true);

  for (var volID in found_nodes["Volumes"]) {
    executor.scheduleTask(() async {
      var vol_info = await _get_data(volID);
      var fsType = vol_info["FilesystemType"] == "msdos"
          ? FSType.FAT16
          : FSType.fromString(vol_info["FilesystemType"]);
      var usedSpace = vol_info["Size"] - vol_info["FreeSpace"];
      var size = vol_info["Size"];
      var freeSpace = vol_info["FreeSpace"];

      var parent_disk = disks.firstWhere((element) =>
          element.fsHandler.path == "/dev/${vol_info["ParentWholeDisk"]}");
      if (fsType == FSType.APFS) {
        usedSpace = ((apfs_data["Containers"] as List).firstWhere((element) =>
                "/dev/${element["ContainerReference"]}" ==
                parent_disk.fsHandler.path)["Volumes"] as List)
            .firstWhere((element) =>
                element["DeviceIdentifier"] ==
                vol_info["DeviceIdentifier"])["CapacityInUse"];
        freeSpace = size - usedSpace;
      }
      parent_disk.volumes.add(Volume(
          fsHandler: Directory(vol_info["DeviceNode"]),
          fsSize: size,
          sizeAvail: freeSpace,
          sizeUsed: usedSpace,
          fsType: fsType,
          mountPoint: (vol_info["MountPoint"] as String).isEmpty
              ? null
              : Directory(vol_info["MountPoint"]),
          isMounted: (vol_info["MountPoint"] as String).isNotEmpty,
          label: vol_info["VolumeName"]));
    });
  }

  await executor.join(withWaiting: true);
  executor.close();
  return disks;
}

Future<Map<dynamic, dynamic>> _query_apfs() async {
  var process = await Process.run("diskutil", ["apfs", "list", "-plist"]);
  if (process.exitCode == _sucess) {
    return PlistParser().parseXml(process.stdout as String);
  } else {
    logger.e("DiskUtil Non-Zero Exit Code: ${process.exitCode}");
    throw "Non-Zero Exit Code";
  }
}

Future<Map<dynamic, dynamic>> _get_data(String id) async {
  var process = await Process.run("diskutil", ["info", "-plist", "/dev/$id"]);

  if (process.exitCode == _sucess) {
    return PlistParser().parseXml(process.stdout);
  } else {
    logger.e("Disk Util Exit Code: ${process.exitCode}");
    throw "Non-Zero Exit Code";
  }
}

Future<Map<String, dynamic>> _query_drives() async {
  Map<String, dynamic> result = {};
  var process = await Process.run("diskutil", ["list", "-plist"]);
  if (process.exitCode == _sucess) {
    var parsedPlist = PlistParser().parseXml(process.stdout as String);
    result["Volumes"] = parsedPlist["AllDisks"];
    result["Disks"] = parsedPlist["WholeDisks"];
    result["Volumes"]!
        .removeWhere((element) => (result["Disks"] as List).contains(element));
    return result;
  } else {
    logger.e("Disk Util Exit Code: ${process.exitCode}");
    throw "Non-Zero Exit Code";
  }
}
