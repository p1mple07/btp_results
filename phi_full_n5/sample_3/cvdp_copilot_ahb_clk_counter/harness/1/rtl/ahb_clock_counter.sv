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
    reg [DATA_WIDTH-1:0] internal_counter;
    reg overflow_flag;
    reg max_counter_value;

    // Counter behavior
    always @(posedge HCLK) begin
        if (!HRESETn) begin
            internal_counter <= 0;
            overflow_flag <= 0;
            max_counter_value <= 0;
        end else begin
            if (HADDR == 0x00) begin
                internal_counter <= internal_counter + 1;
            end else if (HADDR == 0x04) begin
                stop_counter: begin
                    overflow_flag <= 1;
                    if (!HWRITE) begin
                        internal_counter <= 0;
                        overflow_flag <= 0;
                    end
                end
            end else if (HADDR == 0x08) begin
                COUNTER <= internal_counter;
            end else if (HADDR == 0x0C) begin
                HRDATA <= overflow_flag;
            end else if (HADDR == 0x10) begin
                max_counter_value <= internal_counter;
            end
        end
    end

    // Overflow handling
    always @(posedge HCLK) begin
        if (internal_counter == max_counter_value) begin
            overflow_flag <= 1;
        end else begin
            overflow_flag <= 0;
        end
    end

    // Read operation for COUNTER
    assign COUNTER = overflow_flag ? max_counter_value : internal_counter;

    // OKAY response
    assign HRESP = 1'b0;

    // Other logic for HRDATA and AHB interface
    // ...

endmodule : ahb_clock_counter
