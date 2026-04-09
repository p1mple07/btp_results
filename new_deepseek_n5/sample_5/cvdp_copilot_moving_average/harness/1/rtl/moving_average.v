module moving_average (
    input clock,
    input reset,
    input [11:0] data_in,
    output [11:0] data_out
);

    // FIFO buffer for last 8 samples
    reg [11:0] fifo [7:0];
    // Sum register to accumulate the sum of 8 samples
    reg sum_8samples;
    // Output data to be shifted right by 3 for division by 8
    reg [11:0] data_out_reg;

    // Initialize registers to 0
    always @* begin
        fifo[7:0] = 0;
        sum_8samples = 0;
        data_out_reg = 0;
    end

    // Shift FIFO left and load new data
    always clocked (
        clock,
        reset
    ) begin
        if (reset) begin
            fifo[7:0] = 0;
            sum_8samples = 0;
            data_out_reg = 0;
        else begin
            fifo[0] = data_in;
            sum_8samples = sum_8samples + data_in;
            fifo[1:7] = fifo[0:6];
        end
    end

    // Calculate average by shifting sum right by 3
    always clocked (
        clock,
        reset
    ) begin
        if (reset) begin
            data_out_reg = 0;
        else begin
            data_out_reg = sum_8samples >> 3;
        end
    end

    // Output the result
    wire data_out = data_out_reg;
endmodule