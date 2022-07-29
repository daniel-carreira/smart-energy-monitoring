<template>
  <apexchart
    width="100%"
    height="100%"
    :type="config.type"
    :options="options"
    :series="series"
  ></apexchart>
</template>

<script>
export default {
  props: {
    config: Object,
    isBoolean: Boolean
  },
  data() {
    return {
      options: {
      colors:['#F44336'],
        chart: {
          id: "mychart",
        },
        dataLabels: {
          enabled: false
        },
        xaxis: {
          categories: this.config.xAxis,
          labels: {
            show: false
          },
        },
      },
      series: [
        {
          name: this.config.label,
          data: this.config.yAxis,
        },
      ],
    };
  },
  created() {
    if (!this.isBoolean) return

    this.options.yaxis = {}
    this.options.yaxis.max = 2
    this.options.yaxis.labels = {}
    this.options.yaxis.labels.formatter = function(val) {
        if (val == 0) return "No"
        return "Yes"
      }
    this.options.yaxis.labels.show = false
    this.options.stroke = {}
    this.options.stroke.curve = 'stepline'
  },
  watch: {
    config: {
      handler: function (val) {
        this.options.xaxis.categories = val.xAxis
        this.series = [
          {
              name: val.label,
              data: val.yAxis,
          },
        ];
      },
      deep: true,
    },
  },
};
</script>

<style>
</style>