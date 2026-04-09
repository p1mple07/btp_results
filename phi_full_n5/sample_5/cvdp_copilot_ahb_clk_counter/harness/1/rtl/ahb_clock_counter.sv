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
    reg [DATA_WIDTH-1:0] overflow_flag;
    reg [DATA_WIDTH-1:0] max_cnt;
    reg [DATA_WIDTH-1:0] counter_value;

    // Internal state
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            counter_value <= 0;
            overflow_flag <= 0;
            max_cnt <= 0;
        end else begin
            case (HADDR)
                0x00: begin
                    if (HWRITE) counter_value <= counter_value + 1;
                    else begin
                        if (counter_value == max_cnt) overflow_flag <= 1'b1;
                        counter_value <= 0;
                    end
                end
                0x04: begin
                    overflow_flag <= 0;
                end
                0x08: begin
                    data <= counter_value;
                end
                0x0C: begin
                    data <= overflow_flag;
                end
                0x10: begin
                    max_cnt <= HWDATA;
                end
                default: begin
                    data <= 0;
                end
            endcase
        end
    end

    // Output logic
    always @(posedge HSEL or negedge HREADY) begin
        if (!HREADY) begin
            HRDATA <= 0;
            HRESP <= 0;
        end else begin
            HRDATA <= data;
            HRESP <= 0;
        end
    end

    assign COUNTER = counter_value;
    assign HRDATA = data;
    assign HRESP = 0;

endmodule : ahb_clock_counter
