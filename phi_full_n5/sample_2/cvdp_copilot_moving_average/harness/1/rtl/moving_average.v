module moving_average(
    input clk,
    input reset,
    input [11:0] data_in,
    output reg [11:0] data_out
);

    // Internal register to store the sum of the last 8 samples
    reg [23:0] sum_register;
    // Counter to keep track of the number of valid samples
    reg [3:0] valid_samples;

    // Initialize registers
    initial begin
        sum_register = 0;
        valid_samples = 0;
    end

    // Update sum and valid samples on every rising edge of the clock
    always @(posedge clk) begin
        if (reset) begin
            sum_register <= 0;
            valid_samples <= 0;
            data_out <= 0;
        end else begin
            // Add the new input sample to the sum
            sum_register <= sum_register + data_in;
            // Increment the valid samples counter
            valid_samples <= valid_samples + 1;

            // Calculate the moving average if we have at least 8 valid samples
            if (valid_samples >= 8) begin
                data_out <= sum_register / 8;
                // Reset valid samples count after processing 8 samples
                valid_samples <= 0;
            end
        end
    end

endmodule
