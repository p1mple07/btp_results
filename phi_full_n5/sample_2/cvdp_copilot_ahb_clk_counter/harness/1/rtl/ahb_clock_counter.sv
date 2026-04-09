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

    // Internal registers
    reg [ADDR_WIDTH-1:0] addr_start_reg;
    reg [ADDR_WIDTH-1:0] addr_stop_reg;
    reg [ADDR_WIDTH-1:0] addr_counter_reg;
    reg [ADDR_WIDTH-1:0] addr_overflow_reg;
    reg [ADDR_WIDTH-1:0] addr_maxcnt_reg;
    reg [DATA_WIDTH-1:0] counter_value_reg;
    reg overflow_flag_reg;

    // Internal logic
    always @(posedge HCLK) begin
        if (!HRESETn) begin
            // Reset logic
            addr_start_reg <= 0;
            addr_stop_reg <= 0;
            addr_counter_reg <= 0;
            addr_overflow_reg <= 0;
            addr_maxcnt_reg <= 0;
            counter_value_reg <= 0;
            overflow_flag_reg <= 0;
        end else begin
            // Counter logic
            if (HSEL) begin
                case (HADDR)
                    0: addr_start_reg <= 1;
                    4: addr_stop_reg <= 1;
                    8: addr_counter_reg <= counter_value_reg + 1;
                    12: addr_overflow_reg <= overflow_flag_reg;
                    16: addr_maxcnt_reg <= HWDATA;
                    default: addr_counter_reg <= counter_value_reg;
                endcase
            end
        end
    end

    // Read data logic
    assign HRDATA = (HADDR == 8) ? counter_value_reg : (HADDR == 12) ? overflow_flag_reg : 1'b0;

    // Response logic
    assign HRESP = 1'b0;

    // Counter value logic
    always @(posedge HADDR[8]) begin
        if (HWRITE) begin
            if (HADDR == 8) begin
                counter_value_reg <= addr_counter_reg;
            end
        end
    end

    // Overflow logic
    always @(posedge HCLK) begin
        if (HADDR == 12) begin
            overflow_flag_reg <= (counter_value_reg == addr_maxcnt_reg);
        end
    end

endmodule : ahb_clock_counter
