module first_bit_decoder #(
    parameter IN_WIDTH_g = 32,
    parameter IN_REG_g = 1,
    parameter OUT_REG_g = 1,
    parameter PLREGS_g = 1
) (
    input [IN_WIDTH_g-1:0] In_Data,
    input In_Valid,
    input Clk,
    input Rst,
    output reg [$clog2(IN_WIDTH_g)-1:0] Out_FirstBit,
    output reg Out_Found,
    output reg Out_Valid
);

    // Internal variables
    reg [IN_WIDTH_g-1:0] internal_data;
    reg [$clog2(IN_WIDTH_g)-1:0] found_bit;
    reg [$clog2(IN_WIDTH_g)-1:0] stage_output;

    // Pipeline registers
    reg [$clog2(IN_WIDTH_g)-1:0] pipelined_data [PLREGS_g-1:0];

    // Initialize pipeline registers
    initial begin
        if (Rst) begin
            internal_data = 0;
            found_bit = 0;
            pipelined_data = {{IN_WIDTH_g{1'b0}}} << PLREGS_g;
        end
        else begin
            internal_data = In_Data;
            found_bit = In_Valid ? 1'b1 : 1'b0;
            pipelined_data = {internal_data, {1'b0}} << PLREGS_g;
        end
    end

    // Pipeline logic
    always @(posedge Clk or negedge Clk or Rst) begin
        if (Rst) begin
            Out_FirstBit <= 0;
            Out_Found <= 0;
            Out_Valid <= 0;
        end else begin
            pipelined_data[PLREGS_g-1] <= internal_data;
            for (int i = PLREGS_g-2 downto 0) begin
                pipelined_data[i] <= pipelined_data[i+1];
            end
            internal_data <= pipelined_data[0];

            if (internal_data[IN_WIDTH_g-1]) begin
                found_bit <= IN_WIDTH_g-1;
                Out_FirstBit <= found_bit;
                Out_Valid <= 1;
                Out_Found <= 1;
            end
            else begin
                Out_FirstBit <= 0;
                Out_Found <= 0;
                Out_Valid <= 0;
            end
        end
    end

endmodule
