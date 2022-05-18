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
  UnmodifiableListView<Volume> get volumes => UnmodifiableListView(_volumes);

  ///Get the size of the drive in bytes
  int get size => _size;

  ///Get wether this is the OS drive
  bool get isSystemDrive => _isSystemDrive;

  ///Get the current Drive Partition Scheme (MS-DOS or GPT) as a [PTableType] enum
  PTableType get partitionScheme => _pTableType;

  @override
  String toString() =>
      "Disk{fsHandler: $_fsHandler, volumes: ${_volumes.map((e) => e.label.isEmpty ? e.fsHandler : e.label)}, size: $_size bytes, isSystemDrive: $isSystemDrive, Partition Scheme: $partitionScheme}  ";
}
