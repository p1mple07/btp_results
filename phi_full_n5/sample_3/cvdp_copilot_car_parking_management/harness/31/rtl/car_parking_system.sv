     assign time_warning_alert = ((current_time - entry_time[current_slot]) > WARNING_LIMIT && (current_time - entry_time[current_slot]) < OVERSTAY_LIMIT) & !clear ? 1'b1 : 1'b0;
     