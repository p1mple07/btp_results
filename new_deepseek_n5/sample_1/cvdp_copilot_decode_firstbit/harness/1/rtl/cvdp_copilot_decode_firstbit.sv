// Module: rtl/cvdp_copilot_decode_firstbit.sv

// Constants
local constant PL_REG_LIMIT = ($clog2(InWidth_g) - 1);
local constant NEXT_POWER = $nextpow2(InWidth_g);

// Signals
input Clk;
input Rst;
input In_Data;
input In_Valid;
output Out_FirstBit;
output Out_Found;
output Out_Valid;

// Internal signals
reg [InWidth_g-1:0] pipeline [0:PlRegs_g];
reg first_bit_pos, found_bit;

// Initialization
always_comb begin
    pipeline[0] = In_Data;
end

// Processing
always_ff @ (posedge Clk) begin
    if (Rst) begin
        pipeline[0:PlRegs_g] = 0;
        first_bit_pos = 0;
        found_bit = 0;
        Out_Found = 0;
        Out_Valid = 0;
        $validafter(1);
        return;
    end

    // Process each pipeline stage
    for (int i = 0; i < PlRegs_g; i++) begin
        if (i == 0) begin
            pipeline[i+1] = pipeline[i];
            if (In_Valid && (pipeline[i] & 1)) begin
                first_bit_pos = 0;
                found_bit = 1;
            end
        else if (i > 0 && i < PlRegs_g) begin
            pipeline[i] = pipeline[i+1];
            if (found_bit) begin
                first_bit_pos = first_bit_pos + 1;
            end
        end
    end

    // Final stage
    pipeline[0] = first_bit_pos;
    Out_Found = found_bit;
    Out_Valid = 1;
end

// Output
always_comb begin
    Out_FirstBit = pipeline[0];
end