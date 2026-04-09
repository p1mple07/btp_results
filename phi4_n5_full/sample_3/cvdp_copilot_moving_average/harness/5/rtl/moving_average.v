module moving_average(
    input wire clk,
    input wire reset,
    input wire enable,            // New enable signal: 1-bit
    input  wire [11:0] data_in,
    output wire [11:0] data_out
);

    // Internal memory for the last 8 samples
    reg [11:0] memory [7:0];
    // Running sum of the 8 samples (15 bits to accommodate overflow)
    reg [14:0] sum;
    // Write address pointer for the circular buffer
    reg [2:0] write_address;
    // Next address for reading the oldest sample
    wire [2:0] next_address;
    // Register to hold the oldest sample value
    reg [11:0] read_data;

    // Calculate the next address by simply incrementing the write pointer
    assign next_address = write_address + 1'b1;
    // The moving average is computed by shifting the running sum right by 3 bits
    assign data_out = sum[14:3];

    // Write current input to memory only when reset is asserted or when enable is high
    always @(posedge clk) begin
        if (reset) begin
            integer i;
            for (i = 0; i < 8; i = i + 1) begin
                memory[i] <= 12'h0;
            end
        end else if (enable) begin
            memory[write_address] <= data_in;
        end
    end

    // Read the oldest element from memory only when reset is asserted or when enable is high
    always @(posedge clk) begin
        if (reset) begin
            read_data <= 12'h0;
        end else if (enable) begin
            read_data <= memory[next_address];
        end
    end

    // Increment the write address only when reset is asserted or when enable is high
    always @(posedge clk) begin
        if (reset) begin
            write_address <= 3'h0;
        end else if (enable) begin
            write_address <= write_address + 1'b1;
        end
    end

    // Update the running sum only when reset is asserted or when enable is high
    always @(posedge clk) begin
        if (reset) begin
            sum <= 15'h0;
        end else if (enable) begin
            sum <= sum + data_in - read_data;
        end
    end

endmodule