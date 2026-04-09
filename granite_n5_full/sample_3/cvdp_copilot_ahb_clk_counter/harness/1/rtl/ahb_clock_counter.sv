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

// AHB Clock Counter Module Implementation

reg [DATA_WIDTH-1:0] counter; // Counter register
reg start, stop, overflow; // Control signals for start, stop, and overflow functionality
reg [DATA_WIDTH-1:0] max_cnt; // Maximum count value before overflow

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        counter <= 0;
        start <= 0;
        stop <= 0;
        overflow <= 0;
    end else begin
        if (HSEL && (HADDR == ADDR_START)) begin
            start <= HWRITE? HWDATA : 1'b0;
        end
        if (HSEL && (HADDR == ADDR_STOP)) begin
            stop <= HWRITE? HWDATA : 1'b0;
        end
        if (HSEL && (HADDR == ADDR_COUNTER)) begin
            if (start) begin
                counter <= (overflow)? max_cnt : counter + 1;
            end
        end
        if (HSEL && (HADDR == ADDR_OVERFLOW)) begin
            overflow <= counter >= max_cnt? 1'b1 : 1'b0;
        end
        if (HSEL && (HADDR == ADDR_MAXCNT)) begin
            max_cnt <= HWDATA;
        end
        if (HSEL && (HADDR == ADDR_RESET)) begin
            counter <= 0;
            start <= 0;
            stop <= 0;
            overflow <= 0;
        end
    end
end

always @(*) begin
    if (HSEL && (HADDR == ADDR_READ)) begin
        if ((HADDR == ADDR_COUNTER) || (HADDR == ADDR_OVERFLOW)) begin
            HRDATA <= {DATA_WIDTH{1'b0}};
            case (HADDR)
                ADDR_COUNTER: HRDATA <= counter;
                ADDR_OVERFLOW: HRDATA <= overflow;
            endcase
        end
        else begin
            HRDATA <= {DATA_WIDTH{1'b0}};
        end
    end
    else begin
        HRDATA <= {DATA_WIDTH{1'b0}};
    end
    HRESP <= 1'b0; // Always OKAY response
end

endmodule