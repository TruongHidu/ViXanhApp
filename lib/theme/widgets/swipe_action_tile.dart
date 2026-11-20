import 'package:flutter/semantics.dart';
import 'package:flutter/material.dart';

import '../tokens.dart';

/// Một hành động lộ ra khi vuốt dòng sang trái.
@immutable
final class SwipeAction {
  const SwipeAction({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;
}

/// Dòng vuốt sang trái để lộ các nút (Sửa / Xóa). Trình đọc màn hình dùng
/// custom semantics actions thay cho cử chỉ vuốt.
class SwipeActionTile extends StatefulWidget {
  const SwipeActionTile({
    required this.child,
    required this.actions,
    this.actionWidth = 72,
    this.background,
    super.key,
  });

  final Widget child;
  final List<SwipeAction> actions;
  final double actionWidth;

  /// Nền của dòng (che các nút khi đóng). Mặc định là màu bề mặt.
  final Color? background;

  @override
  State<SwipeActionTile> createState() => _SwipeActionTileState();
}

class _SwipeActionTileState extends State<SwipeActionTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );

  double get _maxSlide => widget.actionWidth * widget.actions.length;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _controller.value = (_controller.value - d.primaryDelta! / _maxSlide).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    final open = velocity < -300 || (velocity <= 300 && _controller.value > 0.5);
    open ? _controller.forward() : _controller.reverse();
  }

  void _close() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final background = widget.background ?? Theme.of(context).colorScheme.surface;
    return Semantics(
      customSemanticsActions: {
        for (final a in widget.actions) CustomSemanticsAction(label: a.label): a.onPressed,
      },
      child: GestureDetector(
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: ClipRect(
          child: Stack(
            children: [
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (final a in widget.actions)
                      SizedBox(
                        width: widget.actionWidth,
                        child: ExcludeSemantics(
                          child: Material(
                            color: a.background,
                            child: InkWell(
                              onTap: () {
                                _close();
                                a.onPressed();
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(a.icon, color: a.foreground),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    a.label,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: a.foreground,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.translate(
                  offset: Offset(-_controller.value * _maxSlide, 0),
                  child: child,
                ),
                child: Material(color: background, child: widget.child),
              ),
              // Dòng đang mở: chạm vào phần nội dung thì đóng lại thay vì mở chi tiết.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: _maxSlide,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => IgnorePointer(
                    ignoring: _controller.value == 0,
                    child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _close),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
