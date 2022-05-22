import 'dart:io';

import 'package:disk_util/src/models/fs_type.dart';

///Class contains the basic properties of a Disk Volume (mount status, mount directory, handler, size, fs type and label)
class Volume {
  Directory? _mountPoint;
  late bool _isMounted;
  late final Directory _fsHandler;
  late final int _size;
  late final int _sizeAvail;
  late final int _sizeUsed;
  late final FSType _fsType;
  String? _label;

  Volume(
      {Directory? mountPoint,
      bool isMounted = false,
      required Directory fsHandler,
      required int fsSize,
      required int sizeAvail,
      required int sizeUsed,
      required FSType fsType,
      String? label}) {
    _mountPoint = mountPoint;
    _isMounted = isMounted;
    _fsHandler = fsHandler;
    _size = fsSize;
    _sizeAvail = sizeAvail;
    _sizeUsed = sizeUsed;
    _fsType = fsType;
    _label = label;
  }

  /// Flag if the the volume is currently mounted in the system
  bool get isMounted => _isMounted;

  ///Get the current Directory the Volume is Mounted To
  Directory? get mountPoint => _mountPoint;

  ///Get the handler for this volume (eg. /dev/sdX# for linux, or /dev/disk# on macos )
  Directory get fsHandler => _fsHandler;

  ///Get Volume Size in bytes
  int get size => _size;

  ///Get volume available Space in Bytes
  int get sizeAvailable => _sizeAvail;

  ///Get volume used space in bytes
  int get sizeUsed => _sizeUsed;

  /// Get the Volume FileSystem Type as [FSType] enum class
  FSType get fsType => _fsType;

  ///Get the current label for the Volume, if there is none empty [String] is returned
  String get label => _label ?? "";

  operator ==(Object other) {
    if (other is! Volume) {
      return false;
    }
    return other._isMounted == _isMounted &&
        mountPoint == other.mountPoint &&
        fsHandler == other.fsHandler &&
        size == other.size &&
        sizeAvailable == other.sizeAvailable &&
        sizeUsed == other.sizeUsed &&
        fsType == other.fsType &&
        label == other.label;
  }

  @override
  String toString() =>
      "Volume{isMounted: $_isMounted, mountPoint: ${_mountPoint ?? ""}, fsHandler: $_fsHandler, FS Type: $_fsType, label: $label, size: $_size bytes, available: $_sizeAvail bytes, used: $_sizeUsed bytes}";
}
