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

    // Internal signals
    reg [DATA_WIDTH-1:0] counter_value;
    reg overflow_flag;
    reg [ADDR_WIDTH-1:0] addr;
    reg [2:0] state; // 0: stopped, 1: running, 2: overflowed
    reg startEnable;
    reg stopEnable;
    reg maxCount;

    // Initialize parameters
    parameter clock enableClock = 1;
    parameter maxCountValue = (1 << (DATA_WIDTH-1)) - 1;

    // Address mapping
    always_comb begin
        case (HADDR)
            0x00: begin
                addr = 0x00;
                startEnable = HWRITE & HSEL & HREADY;
                stopEnable = 0;
            end
            0x04: begin
                addr = 0x04;
                startEnable = 0;
                stopEnable = 1;
            end
            0x08: begin
                addr = 0x08;
                startEnable = 0;
                stopEnable = 0;
            end
            0x0C: begin
                addr = 0x0C;
                startEnable = 0;
                stopEnable = 0;
            end
            0x10: begin
                addr = 0x10;
                startEnable = 1;
                stopEnable = 0;
            end
            default: addr = 0;
        endcase
    end

    // State machine
    always_comb begin
        case (state)
            0: // stopped
                if (startEnable && HWRITE & HSEL & HREADY) begin
                    state = 1;
                    counter_value = 0;
                end
                if (stopEnable && HWRITE & HSEL & HREADY) begin
                    state = 2;
                    overflow_flag = 0;
                end
                HRDATA = (state == 1) ? (counter_value) : (overflow_flag ? (maxCount + 1) : 0);
            1: // running
                if (startEnable) state = 0;
                if (stopEnable) begin
                    overflow_flag = 0;
                    state = 2;
                end
                if (overflow_flag) begin
                    counter_value = 0;
                    state = 2;
                end
                else if (clk) counter_value = (counter_value + 1) & (DATA_WIDTH-1);
                HRDATA = (state == 1) ? (counter_value) : (overflow_flag ? (maxCount + 1) : 0);
            2: // overflowed
                overflow_flag = 1;
                HRDATA = (maxCount + 1);
                state = 0;
            default: 
                state = 0;
        endcase
    end

    // Maximum count configuration
    always_comb begin
        if (HWRITE & HSEL & HREADY & addr == 0x10) begin
            maxCount = maxCountValue;
            state = 0;
        end
    end

    // Reset functionality
    always_comb begin
        if (HRESETn) begin
            counter_value = 0;
            overflow_flag = 0;
            state = 0;
            HRDATA = 0;
        end
    end

    // Prepare response
    HRESP = 0;
endmodule