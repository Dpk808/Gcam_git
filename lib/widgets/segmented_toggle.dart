import 'package:flutter/material.dart';

class Segment<T> {
  const Segment({required this.value, required this.icon, this.label});

  final T value;
  final IconData icon;
  final String? label;
}

class SegmentedToggle<T> extends StatefulWidget {
  const SegmentedToggle({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onChanged,
    this.activeColor = const Color(0xFF0A2F6B),
    this.inactiveColor = const Color(0xFF0A2F6B),
    this.activeIconColor = const Color(0xFF0A2F6B),
    this.inactiveIconColor = Colors.white,
    this.activeBackgroundColor = Colors.white,
    this.inactiveBackgroundColor = const Color(0xFF0A2F6B),
    this.height = 44,
    this.borderRadius = 8,
    this.iconSize = 22,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
    this.animationDuration = const Duration(milliseconds: 200),
    this.shadowColor,
    this.shadowBlurRadius = 12,
    this.shadowOffset = const Offset(0, 6),
  });

  final List<Segment<T>> segments;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final Color activeBackgroundColor;
  final Color inactiveBackgroundColor;
  final double height;
  final double borderRadius;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final Duration animationDuration;
  final Color? shadowColor;
  final double shadowBlurRadius;
  final Offset shadowOffset;

  @override
  State<SegmentedToggle<T>> createState() => _SegmentedToggleState<T>();
}

class _SegmentedToggleState<T> extends State<SegmentedToggle<T>> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.inactiveBackgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor ?? Colors.black.withValues(alpha: 0.5),
            blurRadius: widget.shadowBlurRadius,
            offset: widget.shadowOffset,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius - 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final segment in widget.segments)
              _buildSegment(segment, segment.value == widget.selectedValue),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(Segment<T> segment, bool isSelected) {
    final Color background = isSelected
        ? widget.activeBackgroundColor
        : widget.inactiveBackgroundColor;
    final Color iconColor = isSelected
        ? widget.activeIconColor
        : widget.inactiveIconColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!isSelected) widget.onChanged(segment.value);
        },
        child: AnimatedContainer(
          duration: widget.animationDuration,
          curve: Curves.easeInOut,
          color: background,
          padding: widget.padding,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(segment.icon, size: widget.iconSize, color: iconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
