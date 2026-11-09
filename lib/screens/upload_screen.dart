import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/image_paths.dart';
import '../services/image_storage_service.dart';
import 'dashboard_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();

  static const Color _primary = Color(0xFF0A2F6B);

  String? _idPhotoPath;
  String? _idPageHeadPath;
  String? _profileCardPath;
  String? _detailsPath;
  String? _addressPath;
  String? _qrCodePath;

  int get _selectedCount => [
    _idPhotoPath,
    _idPageHeadPath,
    _profileCardPath,
    _detailsPath,
    _addressPath,
    _qrCodePath,
  ].where((p) => p != null).length;

  Future<void> _pick(ImageSlot slot) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      switch (slot) {
        case ImageSlot.idPhoto:
          _idPhotoPath = file.path;
          break;
        case ImageSlot.idPageHead:
          _idPageHeadPath = file.path;
          break;
        case ImageSlot.profileCard:
          _profileCardPath = file.path;
          break;
        case ImageSlot.details:
          _detailsPath = file.path;
          break;
        case ImageSlot.address:
          _addressPath = file.path;
          break;
        case ImageSlot.qr:
          _qrCodePath = file.path;
          break;
      }
    });
  }

  bool get _canContinue =>
      _idPhotoPath != null &&
      _idPageHeadPath != null &&
      _profileCardPath != null &&
      _detailsPath != null &&
      _addressPath != null &&
      _qrCodePath != null;

  Future<void> _saveAndContinue() async {
    if (!_canContinue) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final ImageStorageService storage = ImageStorageService(prefs: prefs);
    final ImagePaths paths = ImagePaths(
      idPhotoPath: _idPhotoPath!,
      idPageHeadPath: _idPageHeadPath!,
      profileCardPath: _profileCardPath!,
      detailsPath: _detailsPath!,
      addressPath: _addressPath!,
      qrCodePath: _qrCodePath!,
    );
    await storage.saveImagePaths(paths);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => DashboardScreen(initialPaths: paths)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Upload Images',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add 6 images',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap a card to select from your gallery. You can change an image anytime.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _Tile(
                    label: 'ID PHOTO',
                    path: _idPhotoPath,
                    onTap: () => _pick(ImageSlot.idPhoto),
                    icon: Icons.person_outline,
                    primary: _primary,
                  ),
                  _Tile(
                    label: 'HEAD PHOTO FOR ID PAGE',
                    path: _idPageHeadPath,
                    onTap: () => _pick(ImageSlot.idPageHead),
                    icon: Icons.badge_outlined,
                    primary: _primary,
                  ),
                  _Tile(
                    label: 'HEAD PHOTO',
                    path: _profileCardPath,
                    onTap: () => _pick(ImageSlot.profileCard),
                    icon: Icons.badge_outlined,
                    primary: _primary,
                  ),
                  _Tile(
                    label: 'DETAILS',
                    path: _detailsPath,
                    onTap: () => _pick(ImageSlot.details),
                    icon: Icons.notes_outlined,
                    primary: _primary,
                  ),
                  _Tile(
                    label: 'ADDRESS',
                    path: _addressPath,
                    onTap: () => _pick(ImageSlot.address),
                    icon: Icons.location_on_outlined,
                    primary: _primary,
                  ),
                  _Tile(
                    label: 'QR CODE',
                    path: _qrCodePath,
                    onTap: () => _pick(ImageSlot.qr),
                    icon: Icons.qr_code_2_outlined,
                    primary: _primary,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_selectedCount/6 selected',
                  style: const TextStyle(color: Colors.black54),
                ),
                TextButton(
                  onPressed: _selectedCount > 0
                      ? () {
                          setState(() {
                            _idPhotoPath = null;
                            _idPageHeadPath = null;
                            _profileCardPath = null;
                            _detailsPath = null;
                            _addressPath = null;
                            _qrCodePath = null;
                          });
                        }
                      : null,
                  child: const Text('Clear all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canContinue ? _saveAndContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ImageSlot { idPhoto, idPageHead, profileCard, details, address, qr }

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.onTap,
    required this.path,
    required this.icon,
    required this.primary,
  });

  final String label;
  final VoidCallback onTap;
  final String? path;
  final IconData icon;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = path != null;
    final Widget content = hasImage
        ? Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(path!), fit: BoxFit.cover),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Change',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      primary.withValues(alpha: 0.15),
                      primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: primary),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tap to upload',
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ],
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AspectRatio(aspectRatio: 1, child: content),
      ),
    );
  }
}
