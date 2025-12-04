import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_drawing/path_drawing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onAnimationFinished});

  final VoidCallback onAnimationFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const double _maxDrawPortion = 0.8;

  late final AnimationController _controller;
  late final Future<_AnimatedSvgData> _svgDataFuture;
  bool _showFullLogo = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _svgDataFuture = _loadAnimatedData();
    _controller.addListener(() {
      if (_controller.value >= _maxDrawPortion && !_showFullLogo) {
        setState(() {
          _showFullLogo = true;
        });
        // Wait 2 seconds then navigate
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            widget.onAnimationFinished();
          }
        });
      }
    });
  }

  Future<_AnimatedSvgData> _loadAnimatedData() async {
    final rawSvg =
        await rootBundle.loadString('assets/images/logo-black.svg');
    final pathRegExp = RegExp(r'<path[^>]*d="([^"]+)"[^>]*>', multiLine: true);
    final paths = <_AnimatedPath>[];
    double totalLength = 0;

    for (final match in pathRegExp.allMatches(rawSvg)) {
      final pathData = match.group(1);
      if (pathData == null || pathData.trim().isEmpty) continue;
      var path = parseSvgPathData(pathData);
      final tag = match.group(0) ?? '';
      final transformMatch =
          RegExp(r'transform="([^"]+)"').firstMatch(tag);
      if (transformMatch != null) {
        path = _applyTransform(path, transformMatch.group(1)!);
      }
      final length = _calculatePathLength(path);
      if (length == 0) continue;
      paths.add(_AnimatedPath(path: path, length: length));
      totalLength += length;
    }

    if (paths.isEmpty) {
      throw StateError('No paths were found inside logo-black.svg');
    }

    Rect? bounds;
    for (final animatedPath in paths) {
      bounds = bounds?.expandToInclude(animatedPath.path.getBounds()) ??
          animatedPath.path.getBounds();
    }

    double cursor = 0;
    for (final animatedPath in paths) {
      animatedPath.intervalStart = cursor / totalLength;
      cursor += animatedPath.length;
      animatedPath.intervalEnd = cursor / totalLength;
    }

    return _AnimatedSvgData(
      paths: paths,
      bounds: bounds ?? Rect.zero,
    );
  }

  static Path _applyTransform(Path path, String transform) {
    var transformed = path;
    final translateRegExp = RegExp(r'translate\(([^)]+)\)');
    for (final match in translateRegExp.allMatches(transform)) {
      final rawValues = match.group(1) ?? '';
      final parts = rawValues
          .split(RegExp(r'[,\s]+'))
          .where((part) => part.isNotEmpty)
          .toList();
      final dx =
          parts.isNotEmpty ? double.tryParse(parts[0]) ?? 0.0 : 0.0;
      final dy =
          parts.length > 1 ? double.tryParse(parts[1]) ?? 0.0 : 0.0;
      transformed = transformed.shift(Offset(dx, dy));
    }
    return transformed;
  }

  static double _calculatePathLength(Path path) {
    double length = 0;
    for (final metric in path.computeMetrics()) {
      length += metric.length;
    }
    return length;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<_AnimatedSvgData>(
        future: _svgDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            if (_controller.status == AnimationStatus.dismissed) {
              _controller.forward();
            }
            return Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: _showFullLogo
                    ? SizedBox(
                        key: const ValueKey('full-logo'),
                        width: 260,
                        height: 260,
                        child: SvgPicture.asset(
                          'assets/images/logo-black.svg',
                          fit: BoxFit.contain,
                        ),
                      )
                    : AnimatedBuilder(
                        key: const ValueKey('animated-drawing'),
                        animation: _controller,
                        builder: (context, _) {
                          final effectiveProgress =
                              (_controller.value * _maxDrawPortion)
                                  .clamp(0.0, _maxDrawPortion)
                                  .toDouble();
                          return CustomPaint(
                            size: const Size.square(260),
                            painter: _LogoPainter(
                              data: snapshot.requireData,
                              progress: effectiveProgress,
                            ),
                          );
                        },
                      ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load logo',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      ),
    );
  }
}

class _AnimatedSvgData {
  const _AnimatedSvgData({required this.paths, required this.bounds});

  final List<_AnimatedPath> paths;
  final Rect bounds;
}

class _AnimatedPath {
  _AnimatedPath({
    required this.path,
    required this.length,
  });

  final Path path;
  final double length;
  double intervalStart = 0;
  double intervalEnd = 0;
}

class _LogoPainter extends CustomPainter {
  _LogoPainter({required this.data, required this.progress});

  final _AnimatedSvgData data;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.bounds.isEmpty) return;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final scale = _calculateScale(size, data.bounds);
    final dx = (size.width - data.bounds.width * scale) / 2 -
        data.bounds.left * scale;
    final dy = (size.height - data.bounds.height * scale) / 2 -
        data.bounds.top * scale;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    for (final animatedPath in data.paths) {
      final localProgress = ((progress - animatedPath.intervalStart) /
              (animatedPath.intervalEnd - animatedPath.intervalStart))
          .clamp(0.0, 1.0);
      if (localProgress <= 0) continue;
      if (localProgress >= 1) {
        canvas.drawPath(animatedPath.path, paint);
      } else {
        final partialPath =
            _extractPartialPath(animatedPath.path, localProgress);
        canvas.drawPath(partialPath, paint);
      }
    }

    canvas.restore();
  }

  static double _calculateScale(Size size, Rect bounds) {
    final availableWidth = size.width * 0.9;
    final availableHeight = size.height * 0.9;
    final widthScale = availableWidth / bounds.width;
    final heightScale = availableHeight / bounds.height;
    return min(widthScale, heightScale);
  }

  Path _extractPartialPath(Path original, double progress) {
    final targetLength = progress * _calculatePathLength(original);
    double currentLength = 0;
    final Path partialPath = Path();

    for (final metric in original.computeMetrics()) {
      final remaining = targetLength - currentLength;
      if (remaining <= 0) break;
      final segmentLength = min(remaining, metric.length);
      partialPath.addPath(metric.extractPath(0, segmentLength), Offset.zero);
      currentLength += segmentLength;
      if (currentLength >= targetLength) break;
    }

    return partialPath;
  }

  static double _calculatePathLength(Path path) {
    double length = 0;
    for (final metric in path.computeMetrics()) {
      length += metric.length;
    }
    return length;
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}
