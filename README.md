# A library for Dart developers

Library will query the OS for disks and volumes and provide infomration about each device.

### Disks

- [X] FileSystem Node (/dev/sdX (linux), /dev/disk# (macos), \\\\.\\\\PhysicalDisk (windwos))
- [X] Disk Size
- [X] Disk is Main OS Drive
- [X] Partition Scheme
- [X] Volumes/Paritions on Disk

### Volumes

- [X] FileSystem Node (/dev/sdX# (linux), /dev/disk#s# (macos))
- [X] Partition Size
- [X] Free Space on Partition
- [X] Space Used on Partition
- [X] FileSystem Type (ext4, apfs, ntfs... see [fs_type.dart](lib/src/models/fs_type.dart))
- [X] Partition Label if any
- [X] Whether partition is mounted
- [X] Partition Mount Point

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:disk_util/disk_util.dart';

main() async {
  //Create instance of DiskUtil Class
  var diskUtil = DiskUtil();
  //Query System for Drives
  List<Disk> drives = await diskUtil.get_disks();
  //Get the volumes for each drive
  var drive_volumes = drives.map((disk) => disk.volumes).toList();
}
```

## Features and bugs
  - [X] Linux Support
    - Works as Expected
  - [X] Mac OS Support
    - Known bug where Volumes appear to be full!
  - [ ] Windows Support
[tracker]: http://example.com/issues/replaceme
