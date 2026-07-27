import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/routine_item_model.dart';
import 'animation_widgets.dart';

class RoutineItemCard extends StatefulWidget {
  final RoutineItemModel routine;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RoutineItemCard({
    super.key,
    required this.routine,
    this.onFavoriteToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<RoutineItemCard> createState() => _RoutineItemCardState();
}

class _RoutineItemCardState extends State<RoutineItemCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Color(widget.routine.colorHex);
    final cardColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
    final border = isDark ? const Color(0xFF1E2D42) : AppColors.lightSurfaceVariant;
    final textPrimary = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final textSecondary = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _pressed = true);
          _ctrl.forward();
        },
        onTapUp: (_) {
          _ctrl.reverse();
          setState(() => _pressed = false);
        },
        onTapCancel: () {
          _ctrl.reverse();
          setState(() => _pressed = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.only(bottom: AppDimensions.md),
          decoration: BoxDecoration(
            color: _pressed
                ? (isDark ? AppColors.darkSurface2 : AppColors.lightSurfaceVariant)
                : cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _pressed ? color.withOpacity(0.4) : border,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(_pressed ? 0.18 : 0.08),
                blurRadius: _pressed ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Color accent bar on left ──────────────────────────
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // ── Main content ─────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.routine.subjectName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            widget.routine.courseCode,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.access_time_rounded,
                                            size: 12, color: textSecondary),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${widget.routine.startTime} – ${widget.routine.endTime}',
                                          style: TextStyle(
                                              fontSize: 12, color: textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: IconButton(
                                  key: ValueKey(widget.routine.isFavorite),
                                  icon: Icon(
                                    widget.routine.isFavorite
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: widget.routine.isFavorite
                                        ? Colors.amber
                                        : textSecondary,
                                    size: 20,
                                  ),
                                  onPressed: widget.onFavoriteToggle,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert_rounded,
                                    size: 18, color: textSecondary),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 32, minHeight: 32),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                onSelected: (v) {
                                  if (v == 'edit' && widget.onEdit != null) {
                                    widget.onEdit!();
                                  }
                                  if (v == 'delete' && widget.onDelete != null) {
                                    widget.onDelete!();
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(children: [
                                      Icon(Icons.edit_rounded, size: 16),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ]),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(children: [
                                      Icon(Icons.delete_outline_rounded,
                                          size: 16, color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Text('Delete',
                                          style: TextStyle(
                                              color: Colors.redAccent)),
                                    ]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 1,
                            color: border,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _InfoChip(
                                icon: Icons.person_outline_rounded,
                                label: widget.routine.teacherName,
                                color: color,
                                isDark: isDark,
                              ),
                              const SizedBox(width: 10),
                              _InfoChip(
                                icon: Icons.meeting_room_outlined,
                                label: widget.routine.roomNo,
                                color: isDark
                                    ? AppColors.darkSecondary
                                    : AppColors.lightSecondary,
                                isDark: isDark,
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.routine.dayOfWeek.substring(0, 3),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.darkOnSurfaceVariant
                : AppColors.lightOnSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
