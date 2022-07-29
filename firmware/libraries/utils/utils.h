#ifndef _UTILS_
#define _UTILS_

class Statistic {
  public:
    static float getMean(float *values, int n);
    static float getVariance(float *values, int n);
};

#endif