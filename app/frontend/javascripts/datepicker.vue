<template>
  <div>
    Period: {{date_preview}}
    <input type="hidden" name="sticky[start_at]" :value="date['start']">
    <input type="hidden" name="sticky[end_at]" :value="date['end']">
    <div class="edit-datepicker">
      <v-date-picker mode="range" :formats="{input: 'YYYY/M/D', data: 'YYYY-MM-DD', dayPopover: 'MMM D YYYY'}" v-model="date" is-inline v-cloak></v-date-picker>
    </div>
    <button type="button" class="mdc-button mdc-button--icon mdc-button--secondary mdc-ripple-upgraded" :disabled="!date.start" v-on:click="clear"><i class="material-icons mdc-button__icon">av_timer</i>スケジュール予約を無効にする</button>
  </div>
</template>

<script>
  import Vue from 'vue/dist/vue.esm';
  import VCalendar from 'v-calendar';
  import 'v-calendar/lib/v-calendar.min.css';
  import moment from 'moment';

  Vue.use(VCalendar, {
    locale: 'en-GB',
    firstDayOfWeek: 1,
    datePickerShowDayPopover: false,
    themeStyles: {
      wrapper: {
        background: null,
        color: null
      },
      dayCellNotInMonth: {
        color: '#dddcdd'
      },
      dayPopoverContent: {
        color: '#333333',
        fontSize: '0.8rem',
        whiteSpace: 'nowrap'
      }
    }
  });

  export default {
    props: ['params'],
    data: function() {
      return {
        date: {
          start: this.params.start ? new Date(this.params.start) : null,
          end: this.params.end ? new Date(this.params.end) : null
        }
      }
    },
    methods: {
      clear: function() {
        this.date = { start: null, end: null };
      }
    },
    computed: {
      date_preview: function() {
        if (!this.date.start) return 'Always';
        let start = moment(this.date.start);
        let end = moment(this.date.end);
        let format;

        if (start.year() === end.year()) {
          if (start.month() === end.month()) {
            if (start.date() === end.date()) {
              return start.format('D MMM, YYYY');
            } else {
              format = 'D';
            }
          } else {
            format = 'D MMM';
          }
        } else {
          format = 'D MMM, YYYY';
        }
        return start.format(format) + ' through ' + end.format('D MMM, YYYY');
      },
    }
  }
</script>