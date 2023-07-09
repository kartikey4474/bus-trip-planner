class RouteDetails {
  final List<String> busNumbers;
  final String? startingStop;
  final String? finalStop;
  final String? busDuration;
  final List<String> intermediateStops;
  final List<String> transfers;

  RouteDetails({
    required this.busNumbers,
    this.startingStop,
    this.finalStop,
    this.busDuration,
    this.intermediateStops = const [],
    this.transfers = const [],
  });
}
