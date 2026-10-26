import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/widgets/common/screen_header.dart';

class DiscoverHeader extends StatefulWidget {
  const DiscoverHeader({
    super.key,
    this.locationName = '',
    this.onNotificationsTap,
    this.onSearchChanged,
  });

  /// Nazwa / adres miejsca dostawy (ucinany do max. ½ szerokości ekranu).
  final String locationName;
  final VoidCallback? onNotificationsTap;
  final ValueChanged<String>? onSearchChanged;

  @override
  State<DiscoverHeader> createState() => _DiscoverHeaderState();
}

class _DiscoverHeaderState extends State<DiscoverHeader>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late final AnimationController _animationController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _searchFocusNode.requestFocus();
      }
      if (status == AnimationStatus.dismissed) {
        _searchController.clear();
        widget.onSearchChanged?.call('');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    _animationController.forward();
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 50,
        child: AnimatedBuilder(
          animation: _expandAnimation,
          builder: (BuildContext context, Widget? child) {
            final double t = _expandAnimation.value;
            final bool showCollapsed = t < 1;

            return Stack(
              children: <Widget>[
                // Collapsed: location + actions
                if (showCollapsed)
                  Opacity(
                    opacity: (1 - t).clamp(0.0, 1.0),
                    child: IgnorePointer(
                      ignoring: t > 0.05,
                      child: Builder(
                        builder: (BuildContext context) {
                          final double halfScreen =
                              MediaQuery.sizeOf(context).width / 2;
                          final String place = widget.locationName.trim();
                          return Row(
                            children: <Widget>[
                              ScreenHeaderButton(
                                child: SvgPicture.asset(
                                  'assets/icons/map-pin-area.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.textPrimary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: halfScreen,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Miejsce dostawy',
                                      style: AppTypography.caption,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      place.isEmpty ? 'Brak adresu' : place,
                                      style: AppTypography.normalBold,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(width: 8),
                              ScreenHeaderButton(
                                onPressed: _openSearch,
                                child: SvgPicture.asset(
                                  'assets/icons/magnifying-glass.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.textPrimary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ScreenHeaderButton(
                                onPressed: widget.onNotificationsTap,
                                child: SvgPicture.asset(
                                  'assets/icons/bell.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.textPrimary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                // Expanded search grows from the right over available width
                if (t > 0)
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return ClipRect(
                        child: Align(
                          alignment: Alignment.centerRight,
                          widthFactor: t,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: Opacity(
                              opacity: t.clamp(0.0, 1.0),
                              child: _SearchField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onChanged: widget.onSearchChanged,
                                onClose: _closeSearch,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onClose,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClose;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
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
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                style: AppTypography.normal,
                cursorColor: AppColors.textPrimary,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Szukaj…',
                  hintStyle: AppTypography.normal.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(25),
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                child: const SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: _CloseIcon(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseIcon extends StatelessWidget {
  const _CloseIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/caret-left.svg',
      width: 24,
      height: 24,
      colorFilter: const ColorFilter.mode(
        AppColors.textPrimary,
        BlendMode.srcIn,
      ),
    );
  }
}
