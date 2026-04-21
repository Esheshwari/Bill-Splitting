import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_formatters.dart';
import '../../providers/app_provider.dart';

class BalanceSummaryScreen extends StatelessWidget {
  const BalanceSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final summary = app.dashboardSummary();
    final entries = summary.monthlyCategorySpend.entries.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Balance summary')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text('You owe ${AppFormatters.money(summary.totalOwed)}'),
                  const SizedBox(height: 8),
                  Text('You are owed ${AppFormatters.money(summary.totalToReceive)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SizedBox(
                height: 260,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 52,
                    sections: List.generate(entries.length, (index) {
                      final entry = entries[index];
                      final colors = [
                        Colors.teal,
                        Colors.orange,
                        Colors.blue,
                        Colors.pink,
                        Colors.green,
                      ];
                      return PieChartSectionData(
                        value: entry.value,
                        title: entry.key,
                        color: colors[index % colors.length],
                        radius: 62,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

