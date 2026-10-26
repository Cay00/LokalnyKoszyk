import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/widgets/common/screen_header.dart';

class DiscoverSearchBar extends StatefulWidget {
  const DiscoverSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    this.filterActive = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final bool filterActive;

  @override
  State<DiscoverSearchBar> createState() => _DiscoverSearchBarState();
}

class _DiscoverSearchBarState extends State<DiscoverSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant DiscoverSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    return Row(
      children: <Widget>[
        Expanded(
          child: Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(25),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 50,
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 13),
                  SvgPicture.asset(
                    'assets/icons/magnifying-glass.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      onChanged: widget.onChanged,
                      style: AppTypography.normal,
                      cursorColor: AppColors.textPrimary,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Szukaj produktów…',
                        hintStyle: AppTypography.normal.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (hasText)
                    InkWell(
                      onTap: () {
                        widget.controller.clear();
                        widget.onChanged('');
                      },
                      splashFactory: NoSplash.splashFactory,
                      child: const SizedBox(
                        width: 40,
                        height: 50,
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ScreenHeaderButton(
          onPressed: widget.onFilterTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              SvgPicture.asset(
                'assets/icons/funnel.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
              if (widget.filterActive)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accentAction,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
