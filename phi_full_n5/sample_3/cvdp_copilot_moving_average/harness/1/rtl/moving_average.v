module moving_average(
    input clk,
    input reset,
    input [11:0] data_in,
    output reg [11:0] data_out
);

    // Internal sum register with enough bit-width
    reg [23:0] sum_register;
    // Memory buffer to store the last 8 samples
    reg [11:0] memory_buffer [7:0];
    // Counter for the number of samples stored
    reg [3:0] count;

    // Update memory buffer on every clock cycle
    always @(posedge clk) begin
        if (reset) begin
            sum_register <= 0;
            memory_buffer <= {8'b0, data_in};
            count <= 0;
        end else begin
            memory_buffer <= {memory_buffer[6:0], data_in};
            count <= count + 1;

            // Calculate moving average
            if (count == 8) begin
                sum_register <= sum_register + memory_buffer[6];
                data_out <= sum_register / 8;
                count <= 0;
            end else begin
                sum_register <= sum_register + memory_buffer[count];
            end
        end
    end

    // Reset logic
    always @(posedge clk or reset) begin
        if (reset) begin
            data_out <= 12'b0;
        end
    end

endmodule
