import 'dart:io';
import 'package:disk_util/disk_util.dart';
import 'package:disk_util/src/handlers/logger.dart';
import 'package:executor/executor.dart';
import 'package:plist_parser/plist_parser.dart';

final int _sucess = 0;

Future<List<Disk>> get_disks() async {
  //List that will hold final List of Disks
  List<Disk> disks = [];
  // Map containing the APFS Container Information
  var apfs_data = {};
  // Executor to handle multiple OS Calls without blocking thread
  var executor = Executor(concurrency: 5);

  //Query system for Drives result is a mapping with "Disks" -> List<String> diskIds, and "Volumes" -> List<String> VolIds
  var found_nodes = await _query_drives();
  //Query APFS Container in a non-blocking way.
  executor
      .scheduleTask<Map<dynamic, dynamic>>(() async => await _query_apfs())
      .then((value) => apfs_data = value);

  //Iterate over the DiskIds
  for (var diskID in found_nodes["Disks"]) {
    //Query info from OS in a non-blocking manner,
    executor.scheduleTask<Disk>(() async {
      var drive_info = await _get_data(diskID);
      // When we have data, create disk structure and append it to disks list when future returns.
      return Disk(
          volumes: [],
          fsHandler: Directory(drive_info["DeviceNode"]),
          size: drive_info["Size"],
          pTableType: (drive_info["Content"] as String).contains("GUID")
              ? PTableType.GPT
              : PTableType.fromString(drive_info["Content"]));
    }).then((disk) => disks.add(disk));
  }

  //Wait for disk list to have been populated and the APFS Container data obtained
  await executor.join(withWaiting: true);
  //Iterate over the VolumeIds
  for (var volID in found_nodes["Volumes"]) {
    //Query Volume information in a non-blocking manner.
    executor.scheduleTask(() async {
      //Get Volume Data
      var vol_info = await _get_data(volID);
      //Check extract important properties from the vol_info
      var fsType = vol_info["FilesystemType"] == "msdos"
          ? FSType.FAT16
          : FSType.fromString(vol_info["FilesystemType"]);
      var usedSpace = vol_info["Size"] - vol_info["FreeSpace"];
      var size = vol_info["Size"];
      var freeSpace = vol_info["FreeSpace"];
      //Get the parent disk for the volume
      var parent_disk = disks.firstWhere((element) =>
          element.fsHandler.path == "/dev/${vol_info["ParentWholeDisk"]}");

      //APFS Specific Section
      if (fsType == FSType.APFS) {
        //Grab volume specific information from the apfs_data
        var apfs_vol_info = ((apfs_data["Containers"] as List).firstWhere(
                (element) =>
                    "/dev/${element["ContainerReference"]}" ==
                    parent_disk.fsHandler.path)["Volumes"] as List)
            .firstWhere((element) =>
                element["DeviceIdentifier"] == vol_info["DeviceIdentifier"]);
        //Check if the volume is the System Container, if it is the parent disk is the System Disk
        if ((apfs_vol_info["Roles"] as List).contains("System")) {
          parent_disk.isSystemDrive = true;
        }
        //Grab How much space the APFS Container is using
        usedSpace = apfs_vol_info["CapacityInUse"];
        //Recompute free space, since all containers must be taken into account
        freeSpace = size -
            usedSpace -
            (parent_disk.volumes.fold<int>(
                0,
                ((previousValue, element) =>
                    previousValue + element.sizeUsed)));
      }
      //Create a new volume and append it to the parent disk.
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
  //Wait for all threads to finish
  await executor.join(withWaiting: true);
  //Close the executor
  executor.close();
  return disks;
}

///Method is used to query the apfs container information, returns a map containg the information for all
///containers in the system
Future<Map<dynamic, dynamic>> _query_apfs() async {
  var process = await Process.run("diskutil", ["apfs", "list", "-plist"]);
  if (process.exitCode == _sucess) {
    return PlistParser().parseXml(process.stdout as String);
  } else {
    logger.e("DiskUtil Non-Zero Exit Code: ${process.exitCode}");
    throw "Non-Zero Exit Code";
  }
}

///Method performs OS query for a particular diskid, returns Parsed PList as a Map
Future<Map<dynamic, dynamic>> _get_data(String id) async {
  var process = await Process.run("diskutil", ["info", "-plist", "/dev/$id"]);

  if (process.exitCode == _sucess) {
    return PlistParser().parseXml(process.stdout);
  } else {
    logger.e("Disk Util Exit Code: ${process.exitCode}");
    throw "Non-Zero Exit Code";
  }
}
///Method Queries the OS for all Physical Disks and Volumes present.
///Returns [Map] with Mapping Disks -> [List] of diskID Strings,
///Volumes -> [List] of volID Strings
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
