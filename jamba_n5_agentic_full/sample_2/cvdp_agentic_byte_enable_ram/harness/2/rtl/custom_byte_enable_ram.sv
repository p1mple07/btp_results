module custom_byte_enable_ram (
    input wire clk,
    input wire [ADDR_WIDTH-1:0] addr_a,
    input wire en_a,
    input wire be_a,
    input wire data_in_a,
    input wire en_b,
    input wire be_b,
    input wire data_in_b,
    input wire data_out_b
);

    localparam ADDR_WIDTH = $clog2(LINES);
    localparam ADDR_BITS = ADDR_WIDTH;

    reg [ADDR_BITS-1:0] addr_reg;
    reg [XLEN/8-1:0] en_reg;
    logic [XLEN/8-1:0][7:0] be_reg;
    logic [XLEN-1:0] data_out;

    always @(posedge clk) begin
        addr_reg <= addr_a;
        en_reg <= en_a;
        be_reg <= be_a;

        if (en_a && en_b) begin
            if (addr_reg == addr_reg) begin
                if (be_reg[7:0] == 8'b0) begin
                    data_out <= data_in_a;
                end else if (be_reg[7:0] == 8'b0) begin
                    data_out <= data_in_b;
                end else begin
                    data_out <= data_in_a;
                end
            end
        end
    end

    assign data_out = data_out;

endmodule
