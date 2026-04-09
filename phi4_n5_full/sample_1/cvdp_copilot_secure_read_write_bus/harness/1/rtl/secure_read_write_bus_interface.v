module secure_read_write_bus_interface #(
    parameter p_configurable_key = 8'hAA,
    parameter p_data_width       = 8,
    parameter p_addr_width       = 8
)(
    input  wire                      i_capture_pulse,  // Clock for capturing inputs
    input  wire                      i_read_write_enable, // 1: read, 0: write
    input  wire                      i_reset_bar,       // Asynchronous active-low reset
    input  wire [p_addr_width-1:0]   i_addr,            // Target address for read/write
    input  wire [p_data_width-1:0]   i_data_in,         // Data to be written (for write ops)
    input  wire [7:0]                i_key_in,          // 8-bit key provided for access
    output reg  [p_data_width-1:0]   o_data_out,        // Data output during read op
    output reg                       o_error            // Error flag: 1 if key mismatch
);

    // Memory array for storing data
    reg [p_data_width-1:0] mem [(1<<p_addr_width)-1:0];

    // Process for read/write operations and asynchronous reset
    always @(posedge i_capture_pulse or negedge i_reset_bar) begin
        if (!i_reset_bar) begin
            // Asynchronous reset: clear all memory and outputs
            integer j;
            for (j = 0; j < (1<<p_addr_width); j = j + 1) begin
                mem[j] <= 0;
            end
            o_data_out <= 0;
            o_error    <= 0;
        end else begin
            if (i_read_write_enable) begin
                // Read operation: if key matches, output memory data; else flag error
                if (i_key_in == p_configurable_key) begin
                    o_data_out <= mem[i_addr];
                    o_error    <= 0;
                end else begin
                    o_data_out <= 0;
                    o_error    <= 1;
                end
            end else begin
                // Write operation: if key matches, write data to memory; else flag error
                if (i_key_in == p_configurable_key) begin
                    mem[i_addr] <= i_data_in;
                    o_data_out <= 0;
                    o_error    <= 0;
                end else begin
                    o_data_out <= 0;
                    o_error    <= 1;
                end
            end
        end
    end

endmodule