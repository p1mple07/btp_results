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

    // Internal signals
    reg [DATA_WIDTH-1:0] counter_value;
    reg overflow_flag;
    reg max_count_value;

    // Counter state
    always @(posedge HCLK) begin
        if (!HRESETn) begin
            counter_value <= 0;
            overflow_flag <= 0;
            max_count_value <= 0;
        end else if (HSEL) begin
            case (HADDR)
                0x00: begin
                    counter_value <= counter_value + 1;
                    overflow_flag <= 0;
                end
                0x04: begin
                    overflow_flag <= 1;
                end
                0x08: begin
                    COUNTER <= counter_value;
                    HRDATA <= counter_value;
                    HRESP <= 0;
                end
                0x0C: begin
                    max_count_value <= HWDATA;
                    overflow_flag <= 0;
                end
                default: begin
                    HRDATA <= 0;
                    HRESP <= 0;
                end
            endcase
        end

        // Overflow condition
        if (counter_value >= max_count_value) begin
            overflow_flag <= 1;
            counter_value <= 0;
        end
    end

    // Reset logic
    always @(posedge HRESETn) begin
        counter_value <= 0;
        overflow_flag <= 0;
    end

endmodule : ahb_clock_counter
