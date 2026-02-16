class RideFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minDistance;
  final double? maxDistance;
  final double? minSafetyScore;
  final double? maxSafetyScore;
  final double? minSpeed;
  final double? maxSpeed;
  final String? timeOfDay;
  final String? terrain;
  final String? searchQuery;

  RideFilter({
    this.startDate,
    this.endDate,
    this.minDistance,
    this.maxDistance,
    this.minSafetyScore,
    this.maxSafetyScore,
    this.minSpeed,
    this.maxSpeed,
    this.timeOfDay,
    this.terrain,
    this.searchQuery,
  });

  RideFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    double? minDistance,
    double? maxDistance,
    double? minSafetyScore,
    double? maxSafetyScore,
    double? minSpeed,
    double? maxSpeed,
    String? timeOfDay,
    String? terrain,
    String? searchQuery,
  }) {
    return RideFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minDistance: minDistance ?? this.minDistance,
      maxDistance: maxDistance ?? this.maxDistance,
      minSafetyScore: minSafetyScore ?? this.minSafetyScore,
      maxSafetyScore: maxSafetyScore ?? this.maxSafetyScore,
      minSpeed: minSpeed ?? this.minSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      terrain: terrain ?? this.terrain,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters {
    return startDate != null ||
        endDate != null ||
        minDistance != null ||
        maxDistance != null ||
        minSafetyScore != null ||
        maxSafetyScore != null ||
        minSpeed != null ||
        maxSpeed != null ||
        timeOfDay != null ||
        terrain != null ||
        (searchQuery != null && searchQuery!.isNotEmpty);
  }

  RideFilter clear() {
    return RideFilter();
  }
}

enum SortOption {
  dateNewest,
  dateOldest,
  distanceLongest,
  distanceShortest,
  safetyBest,
  safetyWorst,
  speedFastest,
  speedSlowest,
}
