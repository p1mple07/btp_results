module ahb_clock_counter #(
    parameter ADDR_WIDTH = 32, // Width of the address bus
    parameter DATA_WIDTH = 32  // Width of the data bus
) (
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

    // Internal signals
    reg [ADDR_WIDTH-1:0] addr;
    reg [DATA_WIDTH-1:0] data;
    reg [DATA_WIDTH-1:0] counter;
    reg [DATA_WIDTH-1:0] overflow;
    reg [DATA_WIDTH-1:0] max_count;
    reg start_flag;
    reg stop_flag;

    // Address decoder
    always @(posedge HSEL) begin
        addr = HADDR;
    end

    // Counter logic
    always @(posedge HCLK) begin
        if (HRESETn) begin
            counter <= 0;
            overflow <= 0;
            start_flag <= 0;
            stop_flag <= 0;
        end else if (start_flag && !stop_flag) begin
            counter <= counter + 1;
            if (counter >= max_count) begin
                overflow <= 1;
                counter <= 0;
            end
        end
    end

    // Read operation
    assign HRDATA = (addr == ADDR_COUNTER) ? counter : 0;
    assign HRDATA = (addr == ADDR_OVERFLOW) ? overflow : HRDATA;
    assign HRDATA = (addr == ADDR_MAXCNT) ? max_count : HRDATA;

    // Write operation
    always @(posedge HWRITE) begin
        case (addr)
            ADDR_START: start_flag <= 1;
            ADDR_STOP: stop_flag <= 1;
            ADDR_MAXCNT: max_count = HWDATA;
            default: data <= HWDATA;
        endcase
    end

    // Reset logic
    always @(posedge HSEL) begin
        if (HRESETn) begin
            overflow <= 0;
            start_flag <= 0;
            stop_flag <= 0;
            counter <= 0;
        end
    end

    // OKAY response
    assign HRESP = 1'b0;

endmodule : ahb_clock_counter
