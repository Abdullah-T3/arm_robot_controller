import 'package:flutter/material.dart';

/// A slider with hover/press feedback, labeling, and value indicator.
class HoverSlider extends StatefulWidget {
  const HoverSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    this.units = '°',
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final String units;

  @override
  State<HoverSlider> createState() => _HoverSliderState();
}

class _HoverSliderState extends State<HoverSlider> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final base = theme.cardColor;

    final bg = _hover ? base.withOpacity(0.9) : base.withOpacity(0.6);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _hover ? cs.primary : base, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text('${widget.value.round()}${widget.units}')
              ],
            ),
            SliderTheme(
              data: theme.sliderTheme.copyWith(
                overlayColor: cs.primary.withOpacity(0.25),
                valueIndicatorTextStyle: theme.textTheme.bodySmall,
                showValueIndicator: ShowValueIndicator.always,
              ),
              child: Slider(
                min: widget.min,
                max: widget.max,
                value: widget.value.clamp(widget.min, widget.max),
                label: '${widget.value.round()}${widget.units}',
                onChanged: widget.onChanged,
              ),
            )
          ],
        ),
      ),
    );
  }
}