
if(state_ff == IDLE) begin
    o_error = (i_sensor[0] | i_sensor[3]) | (&i_operation_sel[2:1]) | (i_operation_sel[1] & i_sensor[1]) | ((i_operation_sel[2] || i_operation_sel[0]) & i_sensor[2]);
end else begin
    o_error = i_sensor[3];
end
