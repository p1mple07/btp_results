module ahb_clock_counter #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input wire HCLK,
    input wire HRESETn,
    input wire HSEL,
    input wire [ADDR_WIDTH-1:0] HADDR,
    input wire HWRITE,
    input wire [DATA_WIDTH-1:0] HWDATA,
    input wire HREADY,
    output reg [DATA_WIDTH-1:0] HRDATA,
    output reg HRESP,
    output reg [DATA_WIDTH-1:0] COUNTER
);

    localparam ADDR_START = HADDR[1];
    localparam ADDR_STOP = HADDR[0];
    localparam ADDR_COUNTER = HADDR[2];
    localparam ADDR_OVERFLOW = HADDR[3];
    localparam ADDR_MAXCNT = HADDR[4];

    always @(*) begin
        case (HRESETn)
            HRESETn: begin
                // Reset all
                counter = 0;
                max_count = 0;
                HRDATA = 0;
                COUNTER = 0;
                HRESP = 1'b0;
            end
        endcase
    end

    always @(posedge HCLK) begin
        if (HWRITE) begin
            if (HADDR == ADDR_START) begin
                counter = 0;
            end else if (HADDR == ADDR_STOP) begin
                counter = 0;
            end else if (HADDR == ADDR_COUNTER) begin
                HRDATA = counter;
            end else if (HADDR == ADDR_OVERFLOW) begin
                HOVERFLOW = 1'b1;
            end else if (HADDR == ADDR_MAXCNT) begin
                max_count = HWDATA;
            end
        end
    end

    assign HRDATA = counter;

    assign COUNTER = counter;

    assign HRESP = 1'b0;

endmodule
