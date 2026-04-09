module moving_average(
    input         clk,
    input         reset,
    input [11:0] data_in,
    output [11:0] data_out
);

    // Internal registers
    reg [11:0] buffer[7]; // 8 elements
    reg [11:0] sum;
    reg full;
    reg [15:0] avg;

    initial begin
        sum = 0;
        full = 0;
        avg = 0;
    end

    always @(posedge clk) begin
        if (~reset) begin
            // Reset on active high reset
            buffer[0] <= 0;
            sum <= 0;
            full <= 0;
            avg <= 0;
        end else begin
            // Process data_in
            if (data_in != 0) begin
                // Shift in new data and shift out oldest
                for (int i = 0; i < 7; i++) begin
                    buffer[i+1] <= buffer[i];
                end
                buffer[7] <= data_in;
                full = 1;
            end else begin
                // If no data, do nothing
            end
        end

        // Compute average
        if (full == 1) begin
            sum = {7{sum[7:0]}};
            avg = sum / 8;
        end
    end

endmodule
