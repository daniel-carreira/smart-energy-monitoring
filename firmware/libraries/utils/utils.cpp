#include "utils.h"

float Statistic::getMean(float *values, int n) {
  float sum = 0;
  for (int i = 0; i < n; i++) {
	sum += values[i];
  }
  return sum / n;
}

float Statistic::getVariance(float *values, int n) {
  float sum = 0;
  float mean = getMean(values, n);
  for (int i = 0; i < n; i++) {
	sum += (values[i] - mean) * (values[i] - mean);
  }
  return sum / n;
}