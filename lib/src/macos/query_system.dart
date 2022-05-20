import 'dart:io';
import 'package:disk_util/disk_util.dart';
import 'package:disk_util/src/handlers/logger.dart';
import 'package:plist_parser/plist_parser.dart';

final int _sucess = 0;

Future<List<Disk>> get_disks() async {
  List<Disk> disks = [];

  var apfs_containers = (await _query_apfs())["Containers"] as List<dynamic>;
  for (var container in apfs_containers) {
    var isOSDrive = false;
    List<Volume> volumes = [];
    for (var volume in container["Volumes"]) {
      if ((volume["Roles"] as List).contains("System")) {
        isOSDrive = true;
      }
      volumes.add(await _get_vol(volume["DeviceIdentifier"]));
    }
    disks.add(Disk(
        fsHandler: Directory("/dev/${container["ContainerReference"]}"),
        size: container["CapacityCeiling"],
        pTableType: PTableType.APFS_Container,
        volumes: volumes,
        isSystemDrive: isOSDrive));
  }
  return disks;
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

Future<Volume> _get_vol(String volumeIdentifier) async {
  var process = await Process.run(
      "diskutil", ["info", "/dev/$volumeIdentifier", "-plist"]);

  if (process.exitCode == _sucess) {
    var volume_info = PlistParser().parseXml(process.stdout);
    return Volume(
        fsHandler: Directory("/dev/$volumeIdentifier"),
        fsSize: volume_info["Size"],
        fsType: FSType.APFS,
        sizeAvail: volume_info["FreeSpace"],
        sizeUsed: volume_info["Size"] - volume_info["FreeSpace"],
        isMounted: (volume_info["MountPoint"] as String).isNotEmpty,
        mountPoint: (volume_info["MountPoint"] as String).isNotEmpty
            ? Directory(volume_info["MountPoint"])
            : null);
  } else {
    logger.e("Unable to get information for disk: $volumeIdentifier");
    throw "Process exit Non-Zero";
  }
}
