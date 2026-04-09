module ahb_clock_counter #(
    parameter ADDR_WIDTH = 32, // Width of the address bus
    parameter DATA_WIDTH = 32  // Width of the data bus
)(
    input  wire                HCLK,      // AHB Clock
    input  wire                HRESETn,   // AHB Reset (Active Low)
    input  wire                HSEL,      // AHB Select
    input  wire [ADDR_WIDTH-1:0] HADDR,    // AHB Address
    input  wire                HWRITE,    // AHB Write Enable
    input  wire [DATA_WIDTH-1:0] HWDATA,   // AHB Write Data
    input  wire                HREADY,    // AHB Ready Signal
    output reg  [DATA_WIDTH-1:0] HRDATA,   // AHB Read Data
    output reg                 HRESP,     // AHB Response (0 = OKAY)
    output reg  [DATA_WIDTH-1:0] COUNTER    // Counter Output
);

    // Define local parameters for the register addresses.
    localparam ADDR_START    = 32'h00;
    localparam ADDR_STOP     = 32'h04;
    localparam ADDR_COUNTER  = 32'h08;
    localparam ADDR_OVERFLOW = 32'h0C;
    localparam ADDR_MAXCNT   = 32'h10;

    // Internal control registers.
    reg running;           // Indicates that the counter is enabled (start/resume)
    reg stop;              // Indicates that the counter is stopped
    reg [DATA_WIDTH-1:0] max_count; // Configurable maximum count value
    reg overflow;          // Overflow flag (set when counter reaches max_count)

    // Synchronous process: handle asynchronous reset, AHB register writes, and counter update.
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            running      <= 1'b0;
            stop         <= 1'b0;
            max_count    <= {DATA_WIDTH{1'b0}};
            COUNTER      <= {DATA_WIDTH{1'b0}};
            overflow     <= 1'b0;
        end
        else begin
            // Process AHB write transactions.
            if (HSEL && HREADY && HWRITE) begin
                case (HADDR)
                    ADDR_START: running <= (HWDATA[0] ? 1'b1 : 1'b0);
                    ADDR_STOP:  stop    <= (HWDATA[0] ? 1'b1 : 1'b0);
                    ADDR_MAXCNT: max_count <= HWDATA;
                    default:    ; // No operation for other addresses.
                endcase
            end

            // Counter update: only increment when enabled (running and not stopped).
            if (running && !stop) begin
                // If counter has reached (or exceeded) the maximum count,
                // set the overflow flag and hold the counter at max_count.
                if (COUNTER >= max_count) begin
                    overflow <= 1'b1;
                    COUNTER  <= max_count;
                end
                else begin
                    COUNTER <= COUNTER + 1;
                end
            end
        end
    end

    // Combinational logic: generate HRDATA based on the current address.
    always @(*) begin
        HRDATA = {DATA_WIDTH{1'b0}};
        if (HSEL && HREADY) begin
            case (HADDR)
                ADDR_COUNTER:  HRDATA = COUNTER;
                ADDR_OVERFLOW: HRDATA = { {DATA_WIDTH-1{1'b0}}, overflow };
                ADDR_MAXCNT:   HRDATA = max_count;
                default:       HRDATA = {DATA_WIDTH{1'b0}};
            endcase
        end
    end

    // AHB response is always OKAY (0).
    always @(*) begin
        HRESP = 1'b0;
    end

endmodule