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

    // Maximum count value
    parameter MAX_COUNT = (1 << DATA_WIDTH) - 1;

    // State machine for counter control
    reg [1:0] state = 0; // 0: Idle, 1: Running

    // Counter array for AHB interface
    reg [DATA_WIDTH-1:0] counter = 0;
    reg [DATA_WIDTH-1:0] max_count = MAX_COUNT;

    // Overflow flag
    reg overflow = 0;

    // Clock enable for counter
    reg clk_enable = 1;

    // Start/Stop control
    always @(HSEL, HADDR) begin
        if (HSEL && HADDR == 0x00) begin
            // Start/Resume counter
            if (state == 0) begin
                state = 1;
                counter = 0;
                overflow = 0;
            end
        end
    end

    // Stop counter
    input stop_enable;

    // Main counter logic
    always @(posedge HCLK or posedgeclk_enable) begin
        if (HRESETn) begin
            counter = 0;
            overflow = 0;
            state = 0;
        end else if (state == 1) begin
            counter = counter + 1;
            counter = counter & max_count;
            
            if (counter > max_count) begin
                overflow = 1;
            end
        end else if (stop_enable) begin
            // Counter stopped
            state = 0;
        end
    end

    // Output data
    HRDATA = (state == 1) ? counter : (HADDR == 0x08 ? counter : (HADDR == 0x0C ? overflow : 0));

    // Always set response
    HRESP = 0;

endmodule