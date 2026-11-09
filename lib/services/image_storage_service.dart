import 'package:shared_preferences/shared_preferences.dart';

import '../models/image_paths.dart';

class ImageStorageService {
  ImageStorageService({required this.prefs});

  final SharedPreferences prefs;

  static const String _keyProfile = 'image_profile';
  static const String _keyIdPhoto = 'image_id_photo';
  static const String _keyIdPageHead = 'image_id_page_head';
  static const String _keyDetails = 'image_details';
  static const String _keyAddress = 'image_address';
  static const String _keyQr = 'image_qr';

  Future<void> saveImagePaths(ImagePaths paths) async {
    await prefs.setString(_keyIdPhoto, paths.idPhotoPath);
    await prefs.setString(_keyIdPageHead, paths.idPageHeadPath);
    await prefs.setString(_keyProfile, paths.profileCardPath);
    await prefs.setString(_keyDetails, paths.detailsPath);
    await prefs.setString(_keyAddress, paths.addressPath);
    await prefs.setString(_keyQr, paths.qrCodePath);
  }

  ImagePaths? _fromPrefs() {
    final String? idPhoto = prefs.getString(_keyIdPhoto);
    final String? idPageHead = prefs.getString(_keyIdPageHead);
    final String? profile = prefs.getString(_keyProfile);
    final String? details = prefs.getString(_keyDetails);
    final String? address = prefs.getString(_keyAddress);
    final String? qr = prefs.getString(_keyQr);

    if (idPhoto == null ||
        idPageHead == null ||
        profile == null ||
        details == null ||
        address == null ||
        qr == null) {
      return null;
    }

    return ImagePaths(
      idPhotoPath: idPhoto,
      idPageHeadPath: idPageHead,
      profileCardPath: profile,
      detailsPath: details,
      addressPath: address,
      qrCodePath: qr,
    );
  }

  Future<ImagePaths?> loadImagePaths() async {
    return _fromPrefs();
  }

  Future<void> clear() async {
    await prefs.remove(_keyIdPhoto);
    await prefs.remove(_keyIdPageHead);
    await prefs.remove(_keyProfile);
    await prefs.remove(_keyDetails);
    await prefs.remove(_keyAddress);
    await prefs.remove(_keyQr);
  }
}
