module data_width_converter(
    input clock,
    input reset,
    input data_in,
    input data_valid,
    output data_out,
    output o_data_out_valid
);

    // State variable: 0=reset, 1=waiting for first input, 2=waiting for second input, 3=waiting for third input, 4=waiting for fourth input
    reg state = 0;

    // Internal buffer to accumulate the four 32-bit inputs
    reg [127:0] buffer = 0;

    // Internal counter to track the number of valid inputs
    reg count = 0;

    // Positive edge sensitivity
    always positive edge clock begin
        case (state)
            0:
                if (reset) begin
                    state = 0;
                    buffer = 0;
                    count = 0;
                end
                else if (data_valid) begin
                    buffer = (data_in << 128 - 32) | buffer;
                    count = 1;
                    state = 1;
                end
            1:
                if (data_valid) begin
                    buffer = (data_in << 128 - 32) | buffer;
                    count = 2;
                    state = 2;
                end
                else begin
                    state = 0;
                    buffer = 0;
                    count = 0;
                end
            2:
                if (data_valid) begin
                    buffer = (data_in << 128 - 32) | buffer;
                    count = 3;
                    state = 3;
                end
                else begin
                    state = 0;
                    buffer = 0;
                    count = 0;
                end
            3:
                if (data_valid) begin
                    buffer = (data_in << 128 - 32) | buffer;
                    count = 4;
                    state = 4;
                end
                else begin
                    state = 0;
                    buffer = 0;
                    count = 0;
                end
            4:
                if (reset) begin
                    state = 0;
                    buffer = 0;
                    count = 0;
                else begin
                    o_data_out = buffer;
                    o_data_out_valid = 1;
                    state = 0;
                    buffer = 0;
                    count = 0;
                end
        end
    end

    // Final output after processing four valid inputs
    always begin
        if (state == 4 && !reset) begin
            o_data_out_valid = 1;
            o_data_out = buffer;
            state = 0;
            buffer = 0;
            count = 0;
        end
    end
endmodule