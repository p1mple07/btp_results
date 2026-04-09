// rtl/cvdp_copilot_decode_firstbit.sv
module first_bit_decoder #(
    parameter IN_WIDTH_G = 32,
    parameter IN_REG_G   = 1,
    parameter OUT_REG_G   = 1,
    parameter PL_REGS_G   = 1
)(
    input wire clk,
    input wire rst,
    input wire in_valid,
    input wire [IN_WIDTH_G-1:0] in_data,
    output reg out_first_bit,
    output reg out_found,
    output reg out_valid
);

    localparam PL_REG_COUNT = PL_REGS_G;
    reg [PL_REG_COUNT-1:0] pipeline;
    reg [IN_WIDTH_G-1:0] temp;

    always @(posedge clk or negedge rst) begin
        if (rst) begin
            pipeline <= {[0:PL_REG_COUNT-1] => 0};
            out_first_bit <= 8'b0;
            out_found   <= 8'b0;
            out_valid    <= 8'b0;
        end else begin
            // Pad the data to the nearest power of two (already handled by the spec)
            // Find the lowest set bit by scanning the data
            assign out_first_bit = 8'b0;
            assign out_found   = 8'b0;
            assign out_valid    = 8'b0;
        end
    end

endmodule
