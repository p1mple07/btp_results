module qam16_demapper_interpolated(
    parameter integer N = 4,
    parameter integer OUT_WIDTH = 4,
    parameter integer IN_WIDTH = 3
);
    input I,
    input Q,
    output bits,
    output error_flag;
    
    packed I packed_I,
    packed Q packed_Q;
    
    integer i;
    integer error_flag_local = 0;
    integer expected_I,
        expected_Q,
        interpolated_I,
        interpolated_Q;
    integer sum_I,
        sum_Q;
    integer abs_diff_I,
        abs_diff_Q;
    packed bits packed_bits;
    
    packed_I = I;
    packed_Q = Q;
    
    for (i = 0; i < (N/2)*2; i++) {
        expected_I = (packed_I[i + 1] + packed_I[i]) / 2;
        expected_Q = (packed_Q[i + 1] + packed_Q[i]) / 2;
        
        interpolated_I = packed_I[i + 1] + (packed_I[i + 1] - packed_I[i])/2;
        interpolated_Q = packed_Q[i + 1] + (packed_Q[i + 1] - packed_Q[i])/2;
        
        sum_I = interpolated_I - expected_I;
        sum_Q = interpolated_Q - expected_Q;
        
        abs_diff_I = abs(sum_I);
        abs_diff_Q = abs(sum_Q);
        
        if (abs_diff_I > 3 || abs_diff_Q > 3) {
            error_flag_local = 1;
        }
    }
    
    packed_bits = (MSB_2 | LSB_2) for each mapped symbol;
    
    error_flag = error_flag_local;
    
    // Mapping I/Q to bits
    packed_bits = (MSB_2 | LSB_2) for each mapped symbol;
    
    // Combine bits into output
    bits = packed_bits;
endmodule