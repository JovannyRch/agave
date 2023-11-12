import 'dart:math' as math;

List<double> calculateSphericalModelSemivariance(
    List<double> lags, double nugget, double sill, double range) {
  return lags.map((h) {
    if (h <= range) {
      return nugget +
          (sill - nugget) *
              (1.5 * (h / range) -
                  0.5 * (h / range) * (h / range) * (h / range));
    } else {
      return nugget + (sill - nugget);
    }
  }).toList();
}

List<double> calculateLinearModelSemivariance(
    List<double> lags, double nugget, double sill, double range) {
  double slope = (sill - nugget) / range;

  return lags.map((h) {
    if (h > range) {
      return sill;
    } else {
      return nugget + slope * h;
    }
  }).toList();
}

List<double> calculateGaussianModelSemivariance(
    List<double> lags, double nugget, double sill, double range) {
  return lags.map((h) {
    return nugget +
        (sill - nugget) * (1 - math.exp(-3 * (h * h) / (range * range)));
  }).toList();
}

List<double> calculateExponentialModelSemivariance(
    List<double> lags, double nugget, double sill, double range) {
  return lags.map((h) {
    return nugget + (sill - nugget) * (1 - math.exp(-3 * h / range));
  }).toList();
}
