module secure_read_write_register_bank #(
    parameter p_address_width = 8,
    parameter p_data_width    = 8,
    parameter p_unlock_code_0 = 8'hAB,
    parameter p_unlock_code_1 = 8'hCD
)(
    input  wire [p_address_width-1:0] i_addr,
    input  wire [p_data_width-1:0]    i_data_in,
    input  wire                       i_read_write_enable, // 0 = write, 1 = read
    input  wire                       i_capture_pulse,     // clock for register bank
    input  wire                       i_rst_n,             // asynchronous active low reset
    output reg  [p_data_width-1:0]    o_data_out
);

    // State encoding for the unlocking mechanism:
    // 00: LOCKED
    // 01: WAIT_FOR_SECOND_CODE (unlock code 0 written correctly)
    // 10: UNLOCKED
    localparam STATE_LOCKED    = 2'b00;
    localparam STATE_WAIT_1    = 2'b01;
    localparam STATE_UNLOCKED  = 2'b10;

    reg [1:0] unlock_state;

    // Register bank memory: one register per address in the addressable space.
    reg [p_data_width-1:0] registers [0: (1 << p_address_width)-1];

    // Write operation: triggered on the rising edge of i_capture_pulse.
    // i_read_write_enable = 0 indicates a write operation.
    always @(posedge i_capture_pulse or negedge i_rst_n) begin
        if (!i_rst_n) begin
            unlock_state <= STATE_LOCKED;
        end else if (!i_read_write_enable) begin  // Write operation
            case(i_addr)
                0: begin
                    // Writing to address 0: must match the unlock code 0.
                    if (i_data_in == p_unlock_code_0)
                        unlock_state <= STATE_WAIT_1;
                    else
                        unlock_state <= STATE_LOCKED;
                    registers[0] <= i_data_in;
                end
                1: begin
                    // Writing to address 1: allowed only if previous unlock code was written correctly.
                    if (unlock_state == STATE_WAIT_1 && i_data_in == p_unlock_code_1)
                        unlock_state <= STATE_UNLOCKED;
                    else
                        unlock_state <= STATE_LOCKED;
                    registers[1] <= i_data_in;
                end
                default: begin
                    // For addresses 2 and above: writing is permitted only when unlocked.
                    if (unlock_state == STATE_UNLOCKED)
                        registers[i_addr] <= i_data_in;
                    // Otherwise, do nothing (write is prevented).
                end
            endcase
        end
    end

    // Read operation: triggered on the rising edge of i_capture_pulse.
    // i_read_write_enable = 1 indicates a read operation.
    always @(posedge i_capture_pulse or negedge i_rst_n) begin
        if (!i_rst_n)
            o_data_out <= {p_data_width{1'b0}};
        else if (i_read_write_enable) begin  // Read operation
            // Addresses 0 and 1 are write-only; always output 0.
            if ((i_addr == 0) || (i_addr == 1))
                o_data_out <= {p_data_width{1'b0}};
            // For addresses 2 and above, output stored data only if unlocked.
            else if (unlock_state == STATE_UNLOCKED)
                o_data_out <= registers[i_addr];
            else
                o_data_out <= {p_data_width{1'b0}};
        end else begin
            // During write operations, o_data_out defaults to 0.
            o_data_out <= {p_data_width{1'b0}};
        end
    end

endmodule