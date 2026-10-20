import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Minimize and maximize/restore buttons for the frameless desktop window.
///
/// They are plain [IconButton]s, i.e. the exact same widget that the Material
/// [CloseButton] next to them is built from, so they automatically share its
/// minimum size, icon size, color and vertical alignment without any extra
/// padding or constraints.
class WindowControlButtons extends StatefulWidget {
  const WindowControlButtons({super.key});

  @override
  State<WindowControlButtons> createState() => _WindowControlButtonsState();
}

class _WindowControlButtonsState extends State<WindowControlButtons>
    with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _syncMaximizedState();
  }

  Future<void> _syncMaximizedState() async {
    final maximized = await windowManager.isMaximized();
    if (!mounted || maximized == _isMaximized) {
      return;
    }
    setState(() => _isMaximized = maximized);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    if (mounted) {
      setState(() => _isMaximized = true);
    }
  }

  @override
  void onWindowUnmaximize() {
    if (mounted) {
      setState(() => _isMaximized = false);
    }
  }

  Future<void> _toggleMaximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: '最小化',
          onPressed: () => windowManager.minimize(),
          icon: const Icon(Icons.remove),
        ),
        IconButton(
          tooltip: _isMaximized ? '向下还原' : '最大化',
          onPressed: _toggleMaximize,
          icon: Icon(_isMaximized ? Icons.filter_none : Icons.crop_square),
        ),
      ],
    );
  }
}
