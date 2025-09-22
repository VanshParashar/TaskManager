// lib/presentation/pages/dashboard_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../../main.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_state.dart';
import '../../core/constants/app_constants.dart';
import 'home_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  List<Color> _kpiGradientColors(BuildContext context, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Prefer using theme colors; fallback to pleasant palettes
    switch (index) {
      case 0:
        return isDark
            ? [theme.colorScheme.primary, theme.colorScheme.primaryContainer]
            : [const Color(0xFF6A11CB), const Color(0xFF8974D6)];
      case 1:
        return isDark
            ? [theme.colorScheme.secondary, theme.colorScheme.secondary.withOpacity(0.8)]
            : [const Color(0xFFF18CD1), const Color(0xFFF6B3F2)];
      case 2:
        return isDark
            ? [Colors.amber.shade700, Colors.amber.shade400]
            : [const Color(0xFFF6B66A), const Color(0xFFF0D59D)];
      case 3:
      default:
        return isDark
            ? [Colors.green.shade400, Colors.green.shade700]
            : [const Color(0xFF5BE08A), const Color(0xFF36C67A)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? theme.colorScheme.background : const Color(0xFFF7F0FF);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            final tasks = (state is TaskLoaded) ? state.tasks : <Task>[];

            // Build KPI map
            final kpis = {
              'In Progress': tasks.where((t) => t.status == TaskStatus.inProgress).length,
              'In Review': tasks.where((t) => t.status == TaskStatus.toDo).length,
              'On Hold': tasks.where((t) => t.status == TaskStatus.toDo).length,
              'Completed': tasks.where((t) => t.status == TaskStatus.done).length,
            };

            // Weekly data: counts per weekday (Mon=1 ... Sun=7) using createdAt
            final Map<int, int> weeklyCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
            for (final t in tasks) {
              final wd = t.createdAt.weekday;
              weeklyCounts[wd] = (weeklyCounts[wd] ?? 0) + 1;
            }

            // Convert to FlSpot list (x: weekday index 1..7 -> 0..6 for chart)
            final spots = <FlSpot>[];
            for (int d = 1; d <= 7; d++) {
              final x = (d - 1).toDouble();
              final y = (weeklyCounts[d] ?? 0).toDouble();
              spots.add(FlSpot(x, y));
            }

            // compute maxY as double (ensure a minimum)
            final double computedMax = weeklyCounts.values.isEmpty
                ? 5.0
                : (weeklyCounts.values.reduce((a, b) => a > b ? a : b)).toDouble() + 2.0;
            final double maxY = computedMax < 5.0 ? 5.0 : computedMax;

            final double horizontalInterval = (maxY / 4.0).clamp(1.0, double.infinity).toDouble();

            // Colors derived from theme for cards and text
            final cardColor = theme.colorScheme.surface;
            final cardBorder = theme.colorScheme.outline.withOpacity(isDark ? 0.08 : 0.12);
            final titleColor = theme.textTheme.headlineSmall?.color ?? theme.colorScheme.onBackground;
            final subtitleColor = theme.textTheme.bodySmall?.color ?? theme.colorScheme.onBackground.withOpacity(0.7);
            final iconColor = theme.iconTheme.color ?? theme.colorScheme.onSurface;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header row
                  Row(
                    children: [
                      Text(
                        'Dashboard',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.notifications_none, color: iconColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // KPI grid 2x2 (cards are tappable)
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.38,
                    children: [
                      _KpiCard(
                        title: 'In Progress',
                        count: kpis['In Progress'] ?? 0,
                        gradient: _kpiGradientColors(context, 0),
                        onTap: () {
                          (rootScreenKey.currentState as dynamic)
                              ?.navigateToTab(0, filter: TaskFilter.inProgress);
                        },
                        cardColor: cardColor,
                        cardBorder: cardBorder,
                        titleColor: theme.colorScheme.onPrimaryContainer ?? theme.colorScheme.onPrimary,
                      ),
                      // _KpiCard(
                      //   title: 'In Review',
                      //   count: kpis['In Review'] ?? 0,
                      //   gradient: _kpiGradientColors(context, 1),
                      //   onTap: () {
                      //     (rootScreenKey.currentState as dynamic)
                      //         ?.navigateToTab(0, filter: TaskFilter.toDo);
                      //   },
                      //   cardColor: cardColor,
                      //   cardBorder: cardBorder,
                      //   titleColor: theme.colorScheme.onPrimaryContainer ?? theme.colorScheme.onPrimary,
                      // ),
                      _KpiCard(
                        title: 'On Hold',
                        count: kpis['On Hold'] ?? 0,
                        gradient: _kpiGradientColors(context, 2),
                        onTap: () {
                          (rootScreenKey.currentState as dynamic)
                              ?.navigateToTab(0, filter: TaskFilter.toDo);
                        },
                        cardColor: cardColor,
                        cardBorder: cardBorder,
                        titleColor: theme.colorScheme.onPrimaryContainer ?? theme.colorScheme.onPrimary,
                      ),
                      _KpiCard(
                        title: 'Completed',
                        count: kpis['Completed'] ?? 0,
                        gradient: _kpiGradientColors(context, 3),
                        onTap: () {
                          (rootScreenKey.currentState as dynamic)
                              ?.navigateToTab(0, filter: TaskFilter.done);
                        },
                        cardColor: cardColor,
                        cardBorder: cardBorder,
                        titleColor: theme.colorScheme.onPrimaryContainer ?? theme.colorScheme.onPrimary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Project statistics title + menu
                  Row(
                    children: [
                      Text('Project Statistics',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          )),
                      const Spacer(),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.more_horiz, color: iconColor)),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Real chart using fl_chart
                  Container(
                    width: double.infinity,
                    height: 180,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withOpacity(0.4) : Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: LineChart(
                      LineChartData(
                        minX: 0.0,
                        maxX: 6.0,
                        minY: 0.0,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: horizontalInterval,
                          getDrawingHorizontalLine: (value) =>
                              FlLine(color: theme.colorScheme.onSurface.withOpacity(0.06), strokeWidth: 1),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: horizontalInterval,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString(),
                                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 1.0,
                              getTitlesWidget: (value, meta) {
                                const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                final idx = value.toInt();
                                final label = (idx >= 0 && idx < 7) ? weekdayLabels[idx] : '';
                                return SideTitleWidget(
                                    child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                    axisSide: meta.axisSide);
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            barWidth: 3.0,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                radius: 3,
                                color: theme.colorScheme.primary,
                                strokeWidth: 0,
                              ),
                            ),
                            belowBarData: BarAreaData(
                                show: true,
                                color: theme.colorScheme.primary.withOpacity(0.12)),
                            color: theme.colorScheme.primary,
                          ),
                        ],
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Summary pills
                  Row(
                    children: [
                      Expanded(
                          child: _SummaryPill(
                              label: 'Total working hour',
                              value: '50:25:06',
                              delta: '↑ 3.4%')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _SummaryPill(
                              label: 'Total task activity',
                              value: '${tasks.length} Task',
                              delta: '↓ 5.0%')),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final int count;
  final List<Color> gradient;
  final VoidCallback? onTap;
  final Color cardColor;
  final Color cardBorder;
  final Color? titleColor;

  const _KpiCard({
    required this.title,
    required this.count,
    required this.gradient,
    this.onTap,
    required this.cardColor,
    required this.cardBorder,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 6, offset: const Offset(0, 4))
          ],
        ),
        child: Stack(
          children: [
            // subtle gradient accent on top-right using provided gradient colors
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(44),
                  // reduce opacity for subtlety
                ),
              ),
            ),

            // content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count.toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: titleColor ?? theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 6),
                Text(title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.more_horiz, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final String delta;
  const _SummaryPill({required this.label, required this.value, required this.delta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = delta.startsWith('↑');
    final cardColor = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outline.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: isPositive ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(delta, style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
