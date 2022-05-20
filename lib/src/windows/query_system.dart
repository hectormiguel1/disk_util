import 'dart:convert';
import 'dart:io';

import 'package:disk_util/disk_util.dart';
import 'package:disk_util/src/handlers/logger.dart';

final int _sucess = 0;
Future<List<Disk>> get_disks() async {
  List<Disk> disks = [];
  var _disk_json = await _get_disks_os();
  for (var disk in _disk_json) {
    var _vols_for_disk = await _get_partition_os(disk["DiskNumber"]);
    List<Volume> volumes = [];
    for (var volume in _vols_for_disk) {
      volumes.add(Volume(
          isMounted: volume["DriveLetter"] != null,
          mountPoint: volume["DriveLetter"] != null
              ? Directory("${volume["DriveLetter"]}:\\")
              : null,
          fsHandler: Directory(volume["Path"]),
          fsSize: volume["Size"],
          sizeAvail: volume["SizeRemaining"],
          sizeUsed: volume["Size"] - volume["SizeRemaining"],
          fsType: FSType.fromString(volume["FileSystem"]),
          label: volume["FileSystemLabel"]));
    }
    disks.add(Disk(
        fsHandler: Directory(disk["Path"]),
        size: disk["Size"],
        pTableType: PTableType.fromString(disk["PartitionStyle"]),
        isSystemDrive: disk["IsSystem"],
        volumes: volumes));
  }
  return disks;
}

Future<List> _get_disks_os() async {
  var process = await Process.run(
      "powershell.exe", ["-c", "Get-Disk | ConvertTo-Json -Depth 1"]);

  if (process.exitCode == _sucess) {
    return jsonDecode(process.stdout as String);
  } else {
    logger.e("Non-Zero exit Code");
    throw "Non-Zero exit Code";
  }
}

Future<List> _get_partition_os(int diskNumber) async {
  var process = await Process.run("powershell.exe", [
    "-c",
    "Get-Partition",
    "-DiskNumber $diskNumber",
    "| Get-Volume | ConvertTo-Json -Depth 2",
  ]);

  if (process.exitCode == _sucess) {
    return jsonDecode(process.stdout as String);
  } else {
    logger.e("Non-Zero exit Code");
    throw "Non-Zero exit Code";
  }
}
