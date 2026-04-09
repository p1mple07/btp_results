module ahb_clock_counter #(
    parameter ADDR_WIDTH = 32, // Width of the address bus
    parameter DATA_WIDTH = 32  // Width of the data bus
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

reg [DATA_WIDTH-1:0] rdata;             // Register for reading data
reg [DATA_WIDTH-1:0] counter;           // Counter value
reg overflow;                            // Overflow flag
reg start;                                // Start/resume flag
reg stop;                                 // Stop flag

// Address decoding logic
always @(*) begin
    case(HADDR)
        16'h00: begin
            if(HWRITE && HSEL) begin
                if(HWDATA == 1'b1)
                    start <= 1'b1;
                else
                    start <= 1'b0;
            end
            rdata = start? 17'd0 : 17'd0;
        end
        16'h04: begin
            if(HWRITE && HSEL) begin
                if(HWDATA == 1'b1)
                    stop <= 1'b1;
                else
                    stop <= 1'b0;
            end
            rdata = stop? 17'd0 : 17'd0;
        end
        16'h08: begin
            rdata = counter;
        end
        16'h0C: begin
            rdata = overflow? 17'd1 : 17'd0;
        end
        16'h10: begin
            if(HWRITE && HSEL) begin
                counter <= HWDATA[DATA_WIDTH-1:0];
                if(counter >= 17'd(2**DATA_WIDTH))
                    overflow <= 1'b1;
                else
                    overflow <= 1'b0;
            end
            rdata = counter;
        end
        default: begin
            rdata = 17'd0;
        end
    endcase
end

// Assign output port values
assign HRDATA = rdata;
assign HRESP = 1'b0;
assign COUNTER = counter;

// Reset logic
always @(posedge HCLK) begin
    if(!HRESETn) begin
        start <= 1'b0;
        stop <= 1'b0;
        counter <= 17'd0;
        overflow <= 1'b0;
    end
end

endmodule