Module declaration
module custom_byte_enable_ram (
    parameter XLEN,
    parameter LINES,
    logical addr_a,
    logical addr_b,
    logical en_a,
    logical en_b,
    logical [XLEN/8-1:0] be_a,
    logical [XLEN/8-1:0] be_b,
    input [XLEN-1:0] data_in_a,
    input [XLEN-1:0] data_in_b,
    output [XLEN-1:0] data_out_a,
    output [XLEN-1:0] data_out_b
);

// Stage-1: Input capturing registers
always @posedge clk begin
    logic [XLEN-1:0] data_in_a_reg = data_in_a;
    logic [XLEN-1:0] data_in_b_reg = data_in_b;
    logic [XLEN-1:0] data_out_a_reg = 0;
    logic [XLEN-1:0] data_out_b_reg = 0;
    logic [ADDR_WIDTH-1:0] addr_a_reg = addr_a;
    logic en_a_reg = en_a;
    logic [XLEN/8-1:0] be_a_reg = be_a;
    logic [ADDR_WIDTH-1:0] addr_b_reg = addr_b;
    logic en_b_reg = en_b;
    logic [XLEN/8-1:0] be_b_reg = be_b;

    // Stage-2: Collision detection and handling
    if (en_a_reg & en_b_reg & (addr_a_reg == addr_b_reg)) begin
        // Select winner between A and B
        if ((be_a_reg & (~be_b_reg)) | (~be_a_reg & be_b_reg)) begin
            data_out_a_reg <= data_in_a_reg;
            data_out_b_reg <= data_in_b_reg;
        else begin
            // Both disabled, no change
            data_out_a_reg <= data_out_a_reg;
            data_out_b_reg <= data_out_b_reg;
        end
    else begin
        // Independent writes
        data_out_a_reg <= data_in_a_reg;
        data_out_b_reg <= data_in_b_reg;
    end
end

// Final output buffering
data_out_a <= data_out_a_reg;
data_out_b <= data_out_b_reg;
endmodule