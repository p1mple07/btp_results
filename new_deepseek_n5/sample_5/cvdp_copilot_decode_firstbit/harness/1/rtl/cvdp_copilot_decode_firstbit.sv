module rtl/cvdp_copilot_decode_firstbit (
    input Clk,
    input Rst,
    input In_Data,
    input In_Valid,
    output Out_FirstBit,
    output Out_Found,
    output Out_Valid
);

    // pipeline registers
    reg [PlRegs_g - 1:0] pipeline_reg;
    reg [InWidth_g - 1:0] bit;
    reg [InWidth_g - 1:0] first_bit;
    reg [InWidth_g - 1:0] found;
    reg Out_Valid_p;

    // internal state
    reg Start;
    reg Done;

    // process
    always_comb begin
        // reset
        if (Rst) begin
            Start = 1;
            Done = 1;
            pipeline_reg = 0;
            first_bit = 0;
            found = 0;
            Out_Valid_p = 0;
            Out_Found = 0;
            Out_FirstBit = 0;
        end else begin
            // process input
            if (In_Reg_g) begin
                // pad input to nearest power of two
                bit = In_Data;
                // process through pipeline
                for (int i = 0; i < PlRegs_g; i++) begin
                    pipeline_reg = bit;
                    bit = bit >> 1;
                    if (pipeline_reg) begin
                        first_bit = i;
                        found = 1;
                    end
                end
                // set output
                Out_Found = found;
                Out_FirstBit = first_bit;
                Out_Valid = Out_Valid_p;
            end else begin
                // propagate output
                Out_Found = Out_Found;
                Out_FirstBit = Out_FirstBit;
                Out_Valid = Out_Valid_p;
            end
        end
    end

    // output
    Out_Valid = Out_Valid_p;
endmodule