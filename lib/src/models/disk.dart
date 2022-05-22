import 'dart:collection';
import 'dart:io';

import 'package:disk_util/src/models/partition_table.dart';
import 'package:disk_util/src/models/volume.dart';

///Class Representing a Physical Disk with its properties.
class Disk {
  late Directory _fsHandler;
  List<Volume> _volumes = [];
  late int _size;
  late bool _isSystemDrive;
  late PTableType _pTableType;

  Disk(
      {required Directory fsHandler,
      List<Volume> volumes = const [],
      required int size,
      bool isSystemDrive = false,
      required PTableType pTableType}) {
    _fsHandler = fsHandler;
    _volumes.addAll(volumes);
    _size = size;
    _isSystemDrive = isSystemDrive;
    _pTableType = pTableType;
  }

  ///Get the handler for this drive (eg. /dev/sdX for linux, or /dev/disk# on macos )
  Directory get fsHandler => _fsHandler;

  ///Get all the current volumes on this drive
  List<Volume> get volumes => _volumes;

  ///Get the size of the drive in bytes
  int get size => _size;

  ///Get wether this is the OS drive
  bool get isSystemDrive => _isSystemDrive;

  set isSystemDrive(bool val) => _isSystemDrive = val;

  ///Get the current Drive Partition Scheme (MS-DOS or GPT) as a [PTableType] enum
  PTableType get partitionScheme => _pTableType;

  operator ==(Object other) {
    if (other is! Disk) {
      return false;
    }
    if (other._volumes.length != _volumes.length) {
      return false;
    }
    for (int i = 0; i < _volumes.length; i++) {
      if (_volumes[i] != other._volumes[i]) {
        return false;
      }
    }
    return other._fsHandler == _fsHandler &&
        other._isSystemDrive == _isSystemDrive &&
        other._pTableType == _pTableType &&
        other._size == _size;
  }

  @override
  String toString() =>
      "Disk{fsHandler: $_fsHandler, volumes: ${_volumes.map((e) => e.label.isEmpty ? e.fsHandler : e.label)}, size: $_size bytes, isSystemDrive: $isSystemDrive, Partition Scheme: $partitionScheme}  ";
}
