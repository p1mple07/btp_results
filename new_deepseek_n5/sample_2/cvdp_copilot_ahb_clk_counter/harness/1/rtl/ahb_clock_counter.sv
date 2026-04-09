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

    reg [DATA_WIDTH-1:0] COUNTER = 0;
    reg OVERFLOW = 0;
    reg RUNNING = 0;

    always @ (posedge HCLK) begin
        if (HSEL && !HRESETn) begin
            case (HADDR)
                0x00: if (HWRITE) begin
                    COUNTER = (COUNTER + 1);
                end
                0x04: if (HWRITE) begin
                    OVERFLOW = (COUNTER == (1 << (ADDR_WIDTH - 1)));
                    COUNTER = 0;
                end
                0x08: if (HWRITE) begin
                    HRDATA = COUNTER;
                end
                0x0C: if (HWRITE) begin
                    HRESP = 1;
                end
                0x10: if (HWRITE) begin
                    COUNTER = (HWDATA >> (DATA_WIDTH - 5));
                end
            end
        end
    end

    // Set response to indicate OKAY
    HRESP = 1;

    // Reset counter and state on reset
    always @ (posedge HCLK or HRESETn) begin
        if (HRESETn) begin
            COUNTER = 0;
            RUNNING = 0;
            OVERFLOW = 0;
        end
    end
endmodule