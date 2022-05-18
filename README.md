A library for Dart developers.

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

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
