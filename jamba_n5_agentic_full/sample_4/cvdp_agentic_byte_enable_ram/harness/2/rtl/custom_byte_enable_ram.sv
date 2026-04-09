module custom_byte_enable_ram #(
    parameter XLEN = 32,
    parameter LINES = 8192
)(
    input clk,
    input [ADDR_WIDTH-1:0] addr_a,
    input [ADDR_WIDTH-1:0] addr_b,
    input en_a,
    input en_b,
    input [XLEN/8-1:0] be_a,
    input [XLEN/8-1:0] be_b,
    input data_in_a,
    input data_in_b,
    output reg [XLEN-1:0] data_out_a,
    output reg [XLEN-1:0] data_out_b
);

localparam ADDR_WIDTH = $clog2(LINES);

// Internal registers
reg [XLEN-1:0] ram [LINES-1:0];
reg [XLEN/8-1:0] addr_a_reg, addr_b_reg;
reg [XLEN/8-1:0] be_a_reg, be_b_reg;
reg [XLEN/8-1:0] data_in_a_reg, data_in_b_reg;

initial begin
    addr_a_reg = 0;
    addr_b_reg = 0;
    be_a_reg = 4'b0000;
    be_b_reg = 4'b0000;
    data_in_a_reg = 32'd0;
    data_in_b_reg = 32'd0;
end

always @(posedge clk) begin
    if (en_a) begin
        // Update data_out_a
        if (addr_a_reg == addr_a) begin
            // Check if data_in_a is valid
            if (data_in_a) begin
                ram[addr_a] = data_in_a;
            end
            // Apply byte-enable
            for (int i = 0; i < XLEN/8; i++) begin
                ram[(addr_a + i) * 8 : (addr_a + i + 1) * 8] = (be_a[i]) ? ram[(addr_a + i) * 8 : (addr_a + i + 1) * 8] : 0;
            end
        end
    end else begin
        if (addr_b_reg == addr_b) begin
            if (data_in_b) begin
                ram[addr_b] = data_in_b;
            end
            for (int i = 0; i < XLEN/8; i++) begin
                ram[(addr_b + i) * 8 : (addr_b + i + 1) * 8] = (be_b[i]) ? ram[(addr_b + i) * 8 : (addr_b + i + 1) * 8] : 0;
            end
        end
    end
end

always @(posedge clk) begin
    if (en_b) begin
        if (addr_b_reg == addr_b) begin
            if (en_b) begin
                data_out_b <= ram[(addr_b) * 8 : (addr_b + 1) * 8];
            end
        end
    end else begin
        data_out_b <= data_out_b;
    end
end

endmodule
