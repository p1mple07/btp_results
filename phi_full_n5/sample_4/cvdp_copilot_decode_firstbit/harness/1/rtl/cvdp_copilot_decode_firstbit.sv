module first_bit_decoder #(
    parameter InWidth_g = 32,
    parameter PlRegs_g = (BinBits_c / 2) - 1
) (
    input [InWidth_g-1:0] In_Data,
    input In_Valid,
    input InReg_g,
    input OutReg_g,
    input Clk,
    input Rst,
    output reg [PlRegs_g-1:0] Out_FirstBit,
    output reg Out_Found,
    output reg Out_Valid
);

    // Internal variables
    reg [InWidth_g-1:0] temp_data;
    reg [PlRegs_g-1:0] intermediate_stage;
    reg [PlRegs_g-1:0] found_bit;

    // Pipeline stages
    always @(posedge Clk or posedge Rst) begin
        if (Rst) begin
            Out_FirstBit <= 0;
            Out_Found <= 0;
            Out_Valid <= 0;
            temp_data <= 0;
            intermediate_stage <= 0;
            found_bit <= 0;
        end else begin
            if (InReg_g) begin
                temp_data <= In_Data;
            end
            // Pipeline processing
            intermediate_stage <= temp_data[PlRegs_g-1:0];
            found_bit <= intermediate_stage[PlRegs_g-1] & intermediate_stage[PlRegs_g-2];
            if (found_bit) begin
                Out_FirstBit <= intermediate_stage[PlRegs_g-1];
                Out_Found <= 1;
                Out_Valid <= 1;
            end else begin
                Out_FirstBit <= 0;
                Out_Found <= 0;
                Out_Valid <= 0;
            end
        end
    end

endmodule
