module qam16_mapper_interpolated #(
    parameter N = 4,
    parameter IN_WIDTH = 4,
    parameter OUT_WIDTH = 3
)(
    input  [N*IN_WIDTH-1:0] bits,
    output reg [OUT_WIDTH*(N+N/2)-1:0] I,
    output reg [OUT_WIDTH*(N+N/2)-1:0] Q
);

reg [OUT_WIDTH*2-1:0] tempI, tempQ;

always @(*) begin
    for (int i = 0; i < N; i++) begin
        // Extract the 4‑bit group
        logic [3:0] group = bits[(4*i) : (4*i+3)];

        // Mapping table for MSB and LSB
        localparam mapping_table = 4'b0000;

        // MSB mapping
        mapping_table[4'b00] = 4'b00; // -3
        mapping_table[4'b01] = 4'b01; // -1
        mapping_table[4'b10] = 4'b10; // 1
        mapping_table[4'b11] = 4'b11; // 3

        // LSB mapping
        mapping_table[4'b00] = 4'b00; // 0
        mapping_table[4'b01] = 4'b01; // 1
        mapping_table[4'b10] = 4'b11; // -1
        mapping_table[4'b11] = 4'b10; // -3

        // Compute contributions
        int msb_contrib = mapping_table[group[3:2]][3:1] ? 3 : 0;
        int lsb_contrib = mapping_table[group[1:0]][3:1] ? 3 : 0;

        // Accumulate to temporary registers
        tempI += msb_contrib;
        tempQ += lsb_contrib;
    end

    // Format I and Q as packed words
    I = {tempI[OUT_WIDTH*2-1:OUT_WIDTH*1-1]};
    Q = {tempQ[OUT_WIDTH*2-1:OUT_WIDTH*1-1]};
end

endmodule
