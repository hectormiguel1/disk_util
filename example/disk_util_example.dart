import 'package:disk_util/disk_util.dart';

void main() {
  DiskUtil().get_disks().then((disks) => disks.forEach((disk) => disk.volumes.forEach((volume) => print(volume))));
  print(DiskUtil.formatSize(940426854400));
}
