module ahb_clock_counter #(
    parameter ADDR_WIDTH = 32, // Width of the address bus
    parameter DATA_WIDTH = 32  // Width of the data bus
)(
    input  wire                HCLK,       // AHB Clock
    input  wire                HRESETn,    // AHB Reset (Active Low)
    input  wire                HSEL,       // AHB Select
    input  wire [ADDR_WIDTH-1:0] HADDR,     // AHB Address
    input  wire                HWRITE,     // AHB Write Enable
    input  wire [DATA_WIDTH-1:0] HWDATA,    // AHB Write Data
    input  wire                HREADY,     // AHB Ready Signal
    output reg  [DATA_WIDTH-1:0] HRDATA,    // AHB Read Data
    output reg                 HRESP,      // AHB Response (OKAY = 0)
    output reg  [DATA_WIDTH-1:0] COUNTER    // Counter Output
);

  // Internal control registers
  reg running;                // 1: counter enabled (start/resume), 0: stopped
  reg [DATA_WIDTH-1:0] max_count; // Configurable maximum count value
  reg overflow;               // Overflow flag (remains set until reset)

  // Synchronous process: register updates and counter operation
  always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
      running      <= 1'b0;
      max_count    <= {DATA_WIDTH{1'b0}};
      COUNTER      <= {DATA_WIDTH{1'b0}};
      overflow     <= 1'b0;
      HRESP        <= 1'b0;  // OKAY response
    end else begin
      // Process AHB transactions if selected and ready
      if (HSEL && HREADY) begin
        case (HADDR[ADDR_WIDTH-1:2])
          2'd0: begin // ADDR_START (0x00): Write 1 to start/resume the counter
                  running <= 1'b1;
                end
          2'd1: begin // ADDR_STOP  (0x04): Write 1 to stop the counter
                  running <= 1'b0;
                end
          2'd4: begin // ADDR_MAXCNT (0x10): Write to configure the maximum count value
                  max_count <= HWDATA;
                end
          default: ; // No action for other addresses on write
        endcase
      end

      // Counter operation: increment if enabled and not at max_count
      if (running) begin
        if (COUNTER == max_count) begin
          overflow <= 1'b1;  // Set overflow flag when maximum is reached
          // Do not increment further; counter remains at max_count
        end else begin
          COUNTER <= COUNTER + 1;
          // Overflow flag remains set if previously set.
        end
      end
    end
  end

  // Combinational logic: generate HRDATA based on address
  always_comb begin
    // Default value for read data
    HRDATA = {DATA_WIDTH{1'b0}};
    if (HSEL && HREADY) begin
      case (HADDR[ADDR_WIDTH-1:2])
        2'd0: HRDATA = running;          // ADDR_START: Return current running state
        2'd1: HRDATA = ~running;          // ADDR_STOP: Return inverted running state
        2'd2: HRDATA = COUNTER;           // ADDR_COUNTER: Return current counter value
        2'd3: HRDATA = {DATA_WIDTH{overflow}}; // ADDR_OVERFLOW: Return overflow flag
        2'd4: HRDATA = max_count;         // ADDR_MAXCNT: Return current max count configuration
        default: HRDATA = {DATA_WIDTH{1'b0}};
      endcase
    end
  end

  // Always indicate OKAY response (HRESP = 0)
  always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
      HRESP <= 1'b0;
    else
      HRESP <= 1'b0;
  end

endmodule