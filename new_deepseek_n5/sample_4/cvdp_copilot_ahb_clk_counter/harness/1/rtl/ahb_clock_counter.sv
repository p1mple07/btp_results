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

    // Internal state variables
    reg counter_Reset = 1;
    reg counter_Current = 0;
    reg counter_OV = 0;
    reg counter_Stop = 0;
    reg clock_enable = 1;

    // Counter max value
    parameter counter_Max = (1 << (DATA_WIDTH - 1));

    // Counter increment
    reg counter_Increment = 0;

    // Clock enable
    always clock_edge HCLK begin
        if (HRESETn) begin
            counter_Reset = 1;
            counter_Current = 0;
            counter_OV = 0;
            counter_Stop = 0;
        end else if (HSEL) begin
            case (HADDR)
                0: begin
                    // Start counter
                    counter_Stop = 0;
                    counter_Increment = 1;
                end
                4: begin
                    // Stop counter
                    counter_Stop = 1;
                    counter_Increment = 0;
                end
                8: begin
                    // Read counter
                    HRDATA = counter_Current;
                end
                C: begin
                    // Read max value
                    HRDATA = counter_Max;
                end
            endcase
        end
    end

    // Counter overflow check
    always clock_edge HCLK begin
        if (counter_Stop == 0 && counter_Current < counter_Max) begin
            counter_Current = (counter_Current + counter_Increment) & ((1 << DATA_WIDTH) - 1);
        end
    end

    // Overflow flag
    always clock_edge HCLK begin
        if (counter_Current >= counter_Max) begin
            counter_OV = 1;
        end
    end

    // Configure max count
    always clock_edge HCLK begin
        if (HADDR == 16) begin
            counter_Max = (1 << (DATA_WIDTH - 1));
        end
    end

    // Ready signal
    always clock_edge HCLK begin
        if (counter_Stop == 0) begin
            HREADY = 1;
        end
    end
endmodule