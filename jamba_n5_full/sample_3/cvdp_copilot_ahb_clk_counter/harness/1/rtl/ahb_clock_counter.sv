module ahb_clock_counter #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input wire HCLK,                       // AHB Clock
    input wire HRESETn,                    // AHB Reset (Active Low)
    input wire HSEL,                       // AHB Select
    input wire [ADDR_WIDTH-1:0] HADDR,     // AHB Address
    input wire HWRITE,                     // AHB Write Enable
    input wire [DATA_WIDTH-1:0] HWDATA,    // AHB Write Data
    input wire HREADY,                     // AHB Ready Signal
    output reg [DATA_WIDTH-1:0] HRDATA,    // AHB Read Data
    output reg HRESP,                      // AHB Response
    output reg [DATA_WIDTH-1:0] COUNTER    // Counter Output
);

// Internal registers
reg [DATA_WIDTH-1:0] counter;
reg overflow;

// Synchronous reset on HRESETn
always @(posedge HCLK) begin
    if (HRESETn) begin
        counter <= 0;
        overflow <= 0;
    end
end

// Assignments to AHB addresses
always @(HWRITE or HADDRESS or HREADY) begin
    case (HADDRESS)
        0x00: counter <= 1'b1; // Start or resume
        0x04: counter <= 1'b0; // Stop
        0x08: counter <= 1'b0; // Reset counter (optional)
        0x0C: counter <= 1'b1; // Set overflow flag
        0x10: counter <= HDATA; // Configure maximum count
    end
end

always @(HREADY or HRESETn) begin
    HRDATA <= counter;
    HRESP = 1'b1;
end

endmodule
