import 'dart:io';

import 'package:flutter/material.dart';

import '../models/image_paths.dart';
import '../widgets/segmented_toggle.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.initialPaths});

  final ImagePaths initialPaths;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

enum ViewMode { idCard, existingApp }

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late ImagePaths _paths;
  final Map<String, Size> _imageSizes = <String, Size>{};
  ViewMode _currentView = ViewMode.idCard;
  double? _idCardHeaderHeight;
  double? _dividerDragStartHeight;
  double? _dividerDragStartY;

  @override
  void initState() {
    super.initState();
    _paths = widget.initialPaths;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    // Preload image sizes for quick diagnostics
    for (final String p in [
      widget.initialPaths.idPhotoPath,
      widget.initialPaths.idPageHeadPath,
      widget.initialPaths.profileCardPath,
      widget.initialPaths.detailsPath,
      widget.initialPaths.addressPath,
      widget.initialPaths.qrCodePath,
    ]) {
      _resolveImageSize(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<_TabConfig> tabs = [
      _TabConfig(title: 'Details', path: _paths.detailsPath),
      _TabConfig(title: 'Address', path: _paths.addressPath),
      _TabConfig(title: 'QR Code', path: _paths.qrCodePath),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(''),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double fixedHeaderHeight =
              constraints.maxWidth / _headerAspectRatio();

          return Stack(
            children: [
              Column(
                children: [
                  _buildHeader(fixedHeaderHeight, constraints.maxHeight),
                  // Content area - switches between ID Card View and Existing App View
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _currentView == ViewMode.idCard
                          ? _buildIdCardView()
                          : _buildExistingAppView(tabs),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 16,
                top: fixedHeaderHeight - 52,
                child: _buildToggle(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImage(String path, BoxFit fit) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: fit);
    }
    return Image.file(File(path), fit: fit);
  }

  Widget _buildInteractiveImage({
    required String path,
    required BoxFit fit,
    Alignment alignment = Alignment.center,
  }) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4,
      boundaryMargin: const EdgeInsets.all(300),
      child: _borderedImageBox(path: path, fit: fit, alignment: alignment),
    );
  }

  Widget _borderedImageBox({
    required String path,
    required BoxFit fit,
    bool useDynamicAspectRatio = false,
    Alignment alignment = Alignment.center,
  }) {
    final Widget imageWidget = useDynamicAspectRatio
        ? AspectRatio(
            aspectRatio: _getImageAspectRatio(path),
            child: _buildImage(path, fit),
          )
        : _buildImage(path, fit);

    return Container(
      decoration: BoxDecoration(color: const Color(0xFFFFFFFF)),
      child: Align(alignment: alignment, child: imageWidget),
    );
  }

  void _resolveImageSize(String path) {
    final ImageProvider provider = path.startsWith('assets/')
        ? AssetImage(path)
        : FileImage(File(path)) as ImageProvider;
    final ImageStream stream = provider.resolve(const ImageConfiguration());
    stream.addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        final Size size = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        );
        if (mounted) {
          setState(() {
            _imageSizes[path] = size;
          });
        }
      }),
    );
  }

  double _getImageAspectRatio(String path) {
    final Size? size = _imageSizes[path];
    if (size != null && size.width > 0 && size.height > 0) {
      return size.width / size.height;
    }
    return 16 / 10;
  }

  double _headerAspectRatio() {
    return _getImageAspectRatio(_paths.profileCardPath);
  }

  Widget _buildHeader(double fixedHeaderHeight, double availableHeight) {
    final Widget image = Container(
      color: Colors.white,
      child: _currentView == ViewMode.idCard
          ? _buildInteractiveImage(
              path: _paths.idPageHeadPath,
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
            )
          : _borderedImageBox(
              path: _paths.profileCardPath,
              fit: BoxFit.contain,
            ),
    );

    if (_currentView != ViewMode.idCard) {
      return SizedBox(height: fixedHeaderHeight, child: image);
    }

    final double headerHeight = _idCardHeaderHeight ?? fixedHeaderHeight;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: headerHeight, child: image),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (DragStartDetails details) {
            _dividerDragStartHeight = headerHeight;
            _dividerDragStartY = details.globalPosition.dy;
          },
          onVerticalDragUpdate: (DragUpdateDetails details) {
            final double maxHeight = availableHeight - 12 - 120;
            final double nextHeight =
                (_dividerDragStartHeight! +
                        details.globalPosition.dy -
                        _dividerDragStartY!)
                    .clamp(120.0, maxHeight);
            setState(() {
              _idCardHeaderHeight = nextHeight;
            });
          },
          onVerticalDragEnd: (_) {
            _dividerDragStartHeight = null;
            _dividerDragStartY = null;
          },
          child: Container(height: 12, color: const Color(0xFFFFFFFF)),
        ),
      ],
    );
  }

  Widget _buildToggle() {
    return SegmentedToggle<ViewMode>(
      segments: const [
        Segment(value: ViewMode.idCard, icon: Icons.format_list_bulleted),
        Segment(value: ViewMode.existingApp, icon: Icons.badge_outlined),
      ],
      selectedValue: _currentView,
      onChanged: (value) {
        setState(() {
          _currentView = value;
        });
      },
      height: 36,
      borderRadius: 8,
      iconSize: 22,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shadowBlurRadius: 12,
      shadowOffset: const Offset(0, 6),
    );
  }

  Widget _buildIdCardView() {
    return Container(
      key: const ValueKey('idCardView'),
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildInteractiveImage(path: _paths.idPhotoPath, fit: BoxFit.cover),
        ],
      ),
    );
  }

  Widget _buildExistingAppView(List<_TabConfig> tabs) {
    return Container(
      key: const ValueKey('existingAppView'),
      color: Colors.white,
      child: Column(
        children: [
          // White background below header image
          Container(height: 2, color: const Color(0xFFFFFFFF)),
          // Curved separator line
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          // Custom middle navbar with animated indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: _MiddleNavBar(
              controller: _tabController,
              items: const [
                _NavItem('DETAILS', Icons.notes_outlined),
                _NavItem('ADDRESS', Icons.location_on_outlined),
                _NavItem('QR CODE', Icons.qr_code_2_outlined),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: Container(
              color: Colors.white,
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: tabs
                    .map(
                      (t) => Padding(
                        padding: EdgeInsets.zero,
                        child: _borderedImageBox(
                          path: t.path,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabConfig {
  _TabConfig({required this.title, required this.path});
  final String title;
  final String path;
}

class _MiddleNavBar extends StatelessWidget {
  const _MiddleNavBar({required this.controller, required this.items});

  final TabController controller;
  final List<_NavItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (int i = 0; i < items.length; i++)
              Expanded(
                child: _NavButton(
                  item: items[i],
                  isSelected: controller.index == i,
                  onTap: () => controller.animateTo(i),
                ),
              ),
          ],
        ),
        // Active tab indicator
        SizedBox(
          height: 3,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double segmentWidth = constraints.maxWidth / items.length;
              const double horizontalInset =
                  16; // inset on both sides within each tab
              final double indicatorWidth =
                  segmentWidth - (horizontalInset * 2);
              final double left =
                  (segmentWidth * controller.index) + horizontalInset;
              return Stack(
                children: [
                  // background remains transparent/white per parent
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    left: left,
                    width: indicatorWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A2F6B),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color textColor = isSelected
        ? const Color(0xFF0A2F6B) // active: dark navy
        : const Color(0xFF5A6FA8); // inactive: slightly darker blue
    final Color iconColor = isSelected
        ? const Color(0xFF0A2F6B)
        : const Color(0xFF5A6FA8);

    final TextStyle textStyle = Theme.of(context).textTheme.titleMedium!
        .copyWith(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, // thicker
          color: textColor,
          fontSize: 16,
          letterSpacing: 0.5,
        );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(item.label, style: textStyle),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}
