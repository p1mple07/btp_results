module first_bit_decoder #(
    parameter int InWidth_g = 32,
    parameter logic InReg_g = 1,
    parameter logic OutReg_g = 1,
    parameter logic PlRegs_g
) (
    input logic clk,
    input logic rst,
    input logic [InWidth_g-1:0] in_data,
    input logic in_valid,
    output logic [$clog2(InWidth_g)-1:0] out_first_bit,
    output logic out_found,
    output logic out_valid
);

    // Internal signals
    logic [$clog2(InWidth_g)-1:0] stage_data [PlRegs_g-1:0];
    logic found, valid;

    // Internal always block
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            stage_data <= {InWidth_g{1'b0}};
            out_found <= 0;
            out_valid <= 0;
        end else begin
            if (in_valid) begin
                stage_data <= {stage_data[PlRegs_g-2:0], in_data};
                found <= stage_data[PlRegs_g-1];
                valid <= found;

                if (found) begin
                    out_first_bit <= $clog2(InWidth_g) - PlRegs_g + 1;
                    out_found <= 1;
                    out_valid <= 1;
                end
            end
        end
    end

    // Outputs
    assign out_first_bit = (PlRegs_g == 0) ? $clog2(InWidth_g) - 1 : out_first_bit;
    assign out_found = found;
    assign out_valid = valid & (PlRegs_g == 0) ? 1'b1 : out_valid;

endmodule
