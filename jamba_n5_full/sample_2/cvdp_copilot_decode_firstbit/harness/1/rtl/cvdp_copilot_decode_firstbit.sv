module first_bit_decoder #(
    parameter INWIDTH_G = 32,
    parameter INREG_G = 1,
    parameter OUTREG_G = 1,
    parameter PLREGS_G = 1
)(
    input clk,
    input rst,
    input clk_dly,
    input [INWIDTH_G-1:0] in_data,
    input in_valid,
    input in_valid_en,
    output reg out_firstbit,
    output reg out_found,
    output reg out_valid
);

localparam CLOG2_INPUT_WIDTH = clog2(INWIDTH_G);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        out_firstbit <= 0;
        out_found <= 0;
        out_valid <= 0;
    end else begin
        if (in_valid_en) begin
            always @(posedge clk) begin
                if (!in_valid) begin
                    out_firstbit <= 0;
                    out_found <= 0;
                    out_valid <= 0;
                end else begin
                    // scan for first set bit
                    localvar int found = 0;
                    for (int i = 0; i < CLOG2_INPUT_WIDTH; i++) begin
                        if (in_data[i]) begin
                            found = i;
                            break;
                        end
                    end
                    out_firstbit <= found;
                    out_found <= 1;
                    out_valid <= 1;
                end
            end
        end else begin
            out_firstbit <= 0;
            out_found <= 0;
            out_valid <= 0;
        end
    end
end

endmodule
