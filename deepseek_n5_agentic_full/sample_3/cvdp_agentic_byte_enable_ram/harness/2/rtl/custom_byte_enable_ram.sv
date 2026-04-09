// Description:
//   Dual-port RAM module supporting byte enable and pipelined operations.
//   Implements collision handling between two independent ports.

parameter XLEN = 32;
parameter LINES = 8192;
localparam ADDR_WIDTH = $clog2(LINES);

// Module parameters
parameterclk = 0;
parameter [ADDR_WIDTH-1:0] addr_a, addr_b;
parameter [1:0] en_a, en_b;
parameter [XLEN/8-1:0] be_a, be_b;
parameter [XLEN-1:0] data_in_a, data_in_b;
parameter [XLEN-1:0] data_out_a, data_out_b;

// Module internals
reg [ADDR_WIDTH-1:0] addr_reg_a, addr_reg_b;
reg [1:0] en_reg_a, en_reg_b;
reg [XLEN/8-1:0] be_reg_a, be_reg_b;
reg [XLEN-1:0] data_in_reg_a, data_in_reg_b;
reg [XLEN-1:0] data_out_reg_a, data_out_reg_b;

// Module ports
always @posedge clk begin
    // Stage 1: Address and enable capture
    addr_reg_a <= addr_a;
    addr_reg_b <= addr_b;
    en_reg_a <= en_a;
    en_reg_b <= en_b;

    // Stage 2: Process writes
    if (en_reg_a && en_reg_b) {
        // Collision detected - check byte-enables
        if ((be_reg_a & (~be_reg_b)) || (be_reg_a & be_reg_b)) {
            // No collision or A has higher priority
            data_out_reg_a <= data_in_reg_a;
            data_out_reg_b <= data_in_reg_b;
        } else if (!be_reg_a && be_reg_b) {
            // B takes precedence
            data_out_reg_a <= data_in_reg_b;
            data_out_reg_b <= data_in_reg_b;
        }
    }

    // Output data (pipelined)
    data_out_a <= data_out_reg_a;
    data_out_b <= data_out_reg_b;
end

// Instantiate the RAM
custom_byte_enable_ram #(
    .XLEN(XLEN),
    .LINES(LINES)
) dut (
    .addr_a(addr_reg_a),
    .addr_b(addr_reg_b),
    .en_a(en_reg_a),
    .en_b(en_reg_b),
    .be_a(be_reg_a),
    .be_b(be_reg_b),
    .data_in_a(data_in_reg_a),
    .data_out_a(data_out_reg_a),
    .data_in_b(data_in_reg_b),
    .data_out_b(data_out_reg_b)
);

// Reset at start
initial begin
    clk = 0;
    repeat(3) #10;
    $finish;
end