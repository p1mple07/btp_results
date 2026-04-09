module single_port_ram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input wire clk,
    input wire we,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout
);

// Memory array
reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

integer i;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
            mem[i] <= {DATA_WIDTH{1'b0}};
        end
    end else if (we) begin
        mem[addr] <= din;
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        dout <= {DATA_WIDTH{1'b0}};
    end else begin
        dout <= mem[addr];
    end
end

endmodule