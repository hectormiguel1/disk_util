import 'package:disk_util/src/linux/query_system.dart';

void main() async {
  var result = await get_disks();
  result.forEach((element) =>
      element.volumes.forEach((element) => print(element.toString() + "\n")));
}
