import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../analytics/data/models/analytics_model.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsSnapshotProvider);
    final selectedDate = ref.watch(selectedAnalyticsDateProvider);
    final l10n = ref.watch(appLocalizationsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref, selectedDate, l10n),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: analyticsAsync.when(
              data: (snapshot) => SliverToBoxAdapter(
                child: ResponsiveContainer(
                  maxWidth: 900,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatCardsGrid(snapshot, context, l10n),
                      const SizedBox(height: 24),
                      _buildActivityTable(snapshot, l10n),
                      const SizedBox(height: 24),
                      _buildPieChart(snapshot, l10n),
                      const SizedBox(height: 24),
                      _buildAttendanceRateBar(
                        l10n.classAttendanceRate,
                        snapshot.classAttendanceRate,
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildAttendanceRateBar(
                        l10n.theDivineLiturgyAttendanceRate,
                        snapshot.theDivineLiturgyAttendanceRate,
                        Colors.purple,
                      ),
                      const SizedBox(height: 24),
                      if (snapshot.absentTheDivineLiturgyNoExcuse.isNotEmpty)
                        _buildWarningBanner(
                          l10n.absentTheDivineLiturgyWarning(
                            snapshot.absentTheDivineLiturgyNoExcuse.length,
                          ),
                          Colors.amber,
                          Icons.warning_rounded,
                        ),
                      if (snapshot.absentClassNoExcuse.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildWarningBanner(
                          l10n.absentClassWarning(
                            snapshot.absentClassNoExcuse.length,
                          ),
                          Colors.orange,
                          Icons.warning_amber_rounded,
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildExcuseTable(
                        l10n.theDivineLiturgyExcusesTitle,
                        snapshot.theDivineLiturgyExcuseRecords,
                        Colors.purple,
                        context,
                        l10n,
                      ),
                      const SizedBox(height: 20),
                      _buildExcuseTable(
                        l10n.classExcusesTitle,
                        snapshot.classExcuseRecords,
                        Colors.blue,
                        context,
                        l10n,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.errorOccurred(err.toString()),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── APP BAR ─────────────
  Widget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    AppLocalizations l10n,
  ) {
    return SliverAppBar(
      expandedHeight: 190,
      floating: true,
      snap: true,
      pinned: false,

      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Stack(
            children: [
              Positioned(
                left: -60,
                top: -40,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                right: -30,
                bottom: -50,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            l10n.analyticsHeader,
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${l10n.dayPrefix} ${l10n.dayName(date.weekday)}",
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          InkWell(
                            onTap: () => _pickDate(context, ref, date),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              ref
                                  .read(selectedAnalyticsDateProvider.notifier)
                                  .updateDate(DateTime.now());
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.today,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
    );
  }

  void _pickDate(BuildContext context, WidgetRef ref, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primaryColor,
            onPrimary: Colors.white,
            onSurface: AppTheme.textDarkColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(selectedAnalyticsDateProvider.notifier).updateDate(picked);
    }
  }

  // ───────────── STAT CARDS ─────────────
  Widget _buildStatCardsGrid(
    AnalyticsSnapshot s,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return GridView.count(
      crossAxisCount: isDesktop ? 4 : (isTablet ? 4 : 2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: isDesktop ? 1.5 : (isTablet ? 1.4 : 1.3),
      children: [
        _StatCard(
          title: l10n.totalStudents,
          value: '${s.totalRegistered}',
          icon: Icons.people_alt_rounded,
          color: AppTheme.primaryColor,
        ),
        _StatCard(
          title: l10n.classAttendance,
          value: '${s.classPresent}',
          icon: Icons.school_rounded,
          color: Colors.blue,
        ),
        _StatCard(
          title: l10n.theDivineLiturgyAttendance,
          value: '${s.theDivineLiturgyPresent}',
          icon: Icons.church_rounded,
          color: Colors.purple,
        ),
        _StatCard(
          title: l10n.attendanceRate,
          value: '${s.classAttendanceRate.toStringAsFixed(0)}%',
          icon: Icons.trending_up_rounded,
          color: s.classAttendanceRate >= 50
              ? AppTheme.presentColor
              : AppTheme.absentColor,
        ),
      ],
    );
  }

  // ───────────── ACTIVITY TABLE ─────────────
  Widget _buildActivityTable(AnalyticsSnapshot s, AppLocalizations l10n) {
    final rows = [
      _ActivityRow(l10n.saturdayClassPresent, s.classPresent, Colors.blue),
      _ActivityRow(
        l10n.fridayTheDivineLiturgyPresent,
        s.theDivineLiturgyPresent,
        Colors.purple,
      ),
      _ActivityRow(l10n.saturdayClassExcuse, s.classExcuse, Colors.orange),
      _ActivityRow(
        l10n.fridayTheDivineLiturgyExcuse,
        s.theDivineLiturgyExcuse,
        Colors.red,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_chart_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  l10n.activityDetails,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ...rows.map(
            (row) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: row.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      row.label,
                      style: GoogleFonts.outfit(fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: row.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${row.count}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: row.color,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── PIE CHART ─────────────
  Widget _buildPieChart(AnalyticsSnapshot s, AppLocalizations l10n) {
    final total =
        s.classPresent +
        s.classExcuse +
        s.theDivineLiturgyPresent +
        s.theDivineLiturgyExcuse;
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            l10n.noAttendanceData,
            style: GoogleFonts.outfit(
              color: AppTheme.textLightColor,
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    final sections = <PieChartSectionData>[
      if (s.classPresent > 0)
        PieChartSectionData(
          value: s.classPresent.toDouble(),
          title: '${s.classPresent}',
          color: Colors.blue,
          radius: 80,
          titleStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (s.theDivineLiturgyPresent > 0)
        PieChartSectionData(
          value: s.theDivineLiturgyPresent.toDouble(),
          title: '${s.theDivineLiturgyPresent}',
          color: Colors.purple,
          radius: 75,
          titleStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (s.classExcuse > 0)
        PieChartSectionData(
          value: s.classExcuse.toDouble(),
          title: '${s.classExcuse}',
          color: Colors.orange,
          radius: 70,
          titleStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (s.theDivineLiturgyExcuse > 0)
        PieChartSectionData(
          value: s.theDivineLiturgyExcuse.toDouble(),
          title: '${s.theDivineLiturgyExcuse}',
          color: Colors.red,
          radius: 70,
          titleStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.attendanceDistribution,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _legendItem(l10n.legendClassPresent, Colors.blue),
              _legendItem(l10n.legendTheDivineLiturgyPresent, Colors.purple),
              _legendItem(l10n.legendClassExcuse, Colors.orange),
              _legendItem(l10n.legendTheDivineLiturgyExcuse, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.outfit(fontSize: 12)),
      ],
    );
  }

  // ───────────── ATTENDANCE RATE BAR ─────────────
  Widget _buildAttendanceRateBar(String label, double rate, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${rate.toStringAsFixed(1)}%',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate / 100,
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── WARNING BANNER ─────────────
  Widget _buildWarningBanner(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.withValues(alpha: 0.8), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── EXCUSE TABLE ─────────────
  Widget _buildExcuseTable(
    String title,
    List<AttendanceRecord> records,
    Color headerColor,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.list_alt_rounded, color: headerColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: headerColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: headerColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${records.length}',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: headerColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    l10n.id,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.name,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    l10n.notes,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.noExcuses,
                style: GoogleFonts.outfit(color: AppTheme.textLightColor),
              ),
            )
          else
            ...records.map(
              (r) => InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(
                        l10n.excuseDetails,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.id,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            r.id,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            l10n.student,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            r.name,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Divider(),
                          Text(
                            l10n.notes,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            r.notes,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            l10n.ok,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          r.id,
                          style: GoogleFonts.outfit(fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          r.name,
                          style: GoogleFonts.outfit(fontSize: 13),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          r.notes.isNotEmpty ? r.notes : '-',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.textLightColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────── HELPER WIDGETS ─────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SafeArea(
                      child: Row(
                        children: [
                          SafeArea(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, color: color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.textLightColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActivityRow {
  final String label;
  final int count;
  final Color color;
  _ActivityRow(this.label, this.count, this.color);
}
