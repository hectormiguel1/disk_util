import 'package:disk_util/src/handlers/logger.dart';

/**
 * Enumaration of most used File Systems, contains Windows, MacOS, and Linux known FileSystems.
 * 
 * Provides Utility to convert from [String] to [FSType]
 */
enum FSType {
  Ext4("ext4"),
  Ext3("ext3"),
  FAT32("fat32"),
  FAT16("vfat"),
  ExFAT("exfat"),
  NTFS("ntfs"),
  APFS("apfs"),
  HFS_Plus("hfs+"),
  HFS("hfs"),
  XFS("xfs"),
  RaiserFS("raiserfs"),
  BTRFS("btrfs"),
  ZFS("zfs"),
  SwapFS("swap"),
  UFS("ufs"),
  TempFS("tmpfs"),
  EFI("efi");

  final String type;

  const FSType(this.type);

  String toString() => type.toUpperCase();

  /**
   * Attempts to convert a [String] to an [FSType] Object.
   * 
   * ! Throws "Unkown FS Type" if unable to convert from [String] to [FSType]
   */
  factory FSType.fromString(String str) {
    for (var e in FSType.values) {
      if (e.type == str.toLowerCase()) return e;
    }
    logger.e("Unkown FS Type: $str");
    throw "Unkown FS Type $str";
  }
}
