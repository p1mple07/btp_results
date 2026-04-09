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

    // Memory buffer to store the last 8 samples
    reg [11:0] sample_buffer [7:0];

    // Initialize the registers
    initial begin
        sum_register = 0;
        valid_samples = 0;
        sample_buffer = {8'b0};
    end

    // Update the sum and valid samples on every clock cycle
    always @(posedge clk) begin
        if (reset) begin
            sum_register <= 0;
            valid_samples <= 0;
            sample_buffer <= {8'b0};
        end else if (valid_samples < 8) begin
            sum_register <= sum_register + data_in;
            valid_samples <= valid_samples + 1;
            sample_buffer <= {sample_buffer[6:0], data_in};
        end else begin
            sum_register <= sum_register - sample_buffer[0] + data_in;
            valid_samples <= valid_samples + 1;
            sample_buffer <= {sample_buffer[6:0], data_in};
        end
    end

    // Calculate the moving average and output it
    always @(posedge clk) begin
        if (valid_samples == 8) begin
            data_out <= sum_register / 8;
        end else begin
            data_out <= 12'b0; // Output zero if not enough samples
        end
    end

endmodule
