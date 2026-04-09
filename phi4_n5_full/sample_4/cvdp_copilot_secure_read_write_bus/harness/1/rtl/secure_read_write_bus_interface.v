module secure_read_write_bus_interface(
    input  wire [p_addr_width-1:0] i_addr,
    input  wire [p_data_width-1:0] i_data_in,
    input  wire [7:0]              i_key_in,
    input  wire                    i_read_write_enable,
    input  wire                    i_capture_pulse,
    input  wire                    i_reset_bar,
    output reg  [p_data_width-1:0] o_data_out,
    output reg                     o_error
);

    // Parameter definitions
    parameter p_configurable_key = 8'hAA;
    parameter p_data_width       = 8;
    parameter p_addr_width       = 8;

    // Calculate memory depth from address width
    localparam integer MEM_DEPTH = (1 << p_addr_width);

    // Internal memory array
    reg [p_data_width-1:0] mem [0:MEM_DEPTH-1];

    // Synchronous operation on rising edge of i_capture_pulse with asynchronous reset
    integer j;
    always @(posedge i_capture_pulse or negedge i_reset_bar) begin
        if (!i_reset_bar) begin
            // Asynchronous reset: clear memory and outputs
            for (j = 0; j < MEM_DEPTH; j = j + 1) begin
                mem[j] <= 0;
            end
            o_data_out <= 0;
            o_error    <= 0;
        end else begin
            // Check authorization key
            if (i_key_in == p_configurable_key) begin
                if (i_read_write_enable) begin
                    // Read operation: output data from memory
                    o_data_out <= mem[i_addr];
                    o_error    <= 0;
                end else begin
                    // Write operation: store data into memory
                    mem[i_addr] <= i_data_in;
                    o_data_out <= 0;
                    o_error    <= 0;
                end
            end else begin
                // Unauthorized access: flag error and default outputs
                o_data_out <= 0;
                o_error    <= 1;
            end
        end
    end

endmodule