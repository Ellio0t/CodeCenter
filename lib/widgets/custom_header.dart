import 'package:flutter/material.dart';
import '../config/app_config.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onRefresh;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const CustomHeader({
    super.key,
    required this.title,
    this.onRefresh,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Background Image (Zoomed)
        Positioned.fill(
          child: Container(
            color: backgroundColor ?? AppConfig.shared.primaryColor,
          ),
        ),

        // 2. Content (AppBar equivalent)
        SafeArea(
          bottom: false,
          child: Container(
            height: 56, // Standard AppBar height
            padding: const EdgeInsets.symmetric(horizontal: 4), // Space for back button
            child: Row(
              children: [
                const BackButton(color: Colors.white),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    iconSize: 30.0,
                    onPressed: onRefresh,
                  ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
