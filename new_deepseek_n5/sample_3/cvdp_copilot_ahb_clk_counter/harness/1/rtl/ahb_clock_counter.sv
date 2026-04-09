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

    // Internal signals
    reg [DATA_WIDTH-1:0] counter = 0;
    reg [DATA_WIDTH-1:0] overflow = 0;
    reg enable = 1;
    reg [ADDR_WIDTH-1:0] max_count = 0;
    reg [ADDR_WIDTH-1:0] compare_result = 0;

    // Compare unit
    always @* begin
        compare_result = (counter == max_count);
    end

    // Counter increment
    always @posedge HCLK begin
        if (enable && !overflow) begin
            counter = (counter + 1) & ((1 << DATA_WIDTH) - 1);
        end
    end

    // Overflow handling
    always @* begin
        if (compare_result) begin
            overflow = 1;
        end
    end

    // Reset handling
    always @* begin
        if (HRESETn) begin
            counter = 0;
            overflow = 0;
            enable = 1;
        end
    end

    // Address mapping
    always HSEL #1, HADDR, enable, overflow, counter, max_count, compare_result;

    // Output ports
    HRDATA = COUNTER;
    HRESP = 0;
endmodule