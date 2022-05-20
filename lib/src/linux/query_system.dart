import 'dart:convert';
import 'dart:io';

import 'package:disk_util/src/handlers/logger.dart';
import 'package:disk_util/src/models/disk.dart';
import 'package:disk_util/src/models/fs_type.dart';
import 'package:disk_util/src/models/partition_table.dart';
import 'package:disk_util/src/models/volume.dart';

///Query the Disks from the OS
///Returns a list of found drives
Future<List<Disk>> get_disks() async {
  List<Disk> disks = [];
  var blockDevices = (await _perfom_os_call())['blockdevices'] as List<dynamic>;

  for (var device in blockDevices) {
    bool isSystemDrive = false;
    disks.add(Disk(
      fsHandler: Directory(device['path']),
      size: device['size'],
      volumes: device['children'] != null? (device['children'] as List<dynamic>).map((element){
        bool isMounted = (element['mountpoint']) != null;
        String? mountpoint = element['mountpoint'];
        if (isMounted) {
          if("/" == mountpoint!)
            isSystemDrive = true;
        }
        return Volume(
          fsHandler:  Directory(element['path']),
          fsSize: element['size'],
          mountPoint: isMounted? Directory(mountpoint!) : null,
          isMounted:  isMounted,
          sizeAvail:  int.parse(element['fsavail']),
          sizeUsed:  int.parse(element['fsused']),
          label: element['label'],
          fsType: FSType.fromString(element['fstype'])
        );
      }).toList() : [],
      isSystemDrive: isSystemDrive,
      pTableType: PTableType.fromString(device['pttype'] ?? PTableType.LOOP.type ))
    );
  }
  logger.i("Found ${disks.length} Drives");
  //Remove Loop Devices as these are not important for user data. 
  disks.removeWhere((disk) => disk.partitionScheme == PTableType.LOOP);
  return disks;
}

final int _sucess = 0;

///Performs the underlaying system call to get devices from system.
///Uses lsblk to query the system
Future<Map<String, dynamic>> _perfom_os_call() async {
  var process = await Process.run('lsblk', ["-b", "-o", "PATH,SIZE,FSAVAIL,FSUSED,FSTYPE,MOUNTPOINT,LABEL,PTTYPE", "-J", '--tree']);
  if(process.exitCode == _sucess) {
    return jsonDecode(process.stdout as String);
  } else {
    logger.e("lsblk non-zero exit status.\nError:${process.stderr as String}");
    throw "lsblk non-zero exit: ${process.exitCode}";
  }
}