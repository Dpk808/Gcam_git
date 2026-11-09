class ImagePaths {
  final String idPhotoPath;
  final String idPageHeadPath;
  final String profileCardPath;
  final String detailsPath;
  final String addressPath;
  final String qrCodePath;

  const ImagePaths({
    required this.idPhotoPath,
    required this.idPageHeadPath,
    required this.profileCardPath,
    required this.detailsPath,
    required this.addressPath,
    required this.qrCodePath,
  });

  List<String> toList() => [
    idPhotoPath,
    idPageHeadPath,
    profileCardPath,
    detailsPath,
    addressPath,
    qrCodePath,
  ];
}
