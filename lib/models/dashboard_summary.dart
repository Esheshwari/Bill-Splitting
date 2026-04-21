class DashboardSummary {
  const DashboardSummary({
    required this.totalOwed,
    required this.totalToReceive,
    required this.monthlyCategorySpend,
  });

  final double totalOwed;
  final double totalToReceive;
  final Map<String, double> monthlyCategorySpend;
}

