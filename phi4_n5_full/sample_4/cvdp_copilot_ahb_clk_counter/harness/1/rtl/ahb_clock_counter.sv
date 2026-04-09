module ahb_clock_counter #(
    parameter ADDR_WIDTH = 32, // Width of the address bus
    parameter DATA_WIDTH = 32  // Width of the data bus
)(
    input  wire                 HCLK,      // AHB Clock
    input  wire                 HRESETn,   // AHB Reset (Active Low)
    input  wire                 HSEL,      // AHB Select
    input  wire [ADDR_WIDTH-1:0] HADDR,    // AHB Address
    input  wire                 HWRITE,    // AHB Write Enable
    input  wire [DATA_WIDTH-1:0] HWDATA,   // AHB Write Data
    input  wire                 HREADY,    // AHB Ready Signal
    output reg  [DATA_WIDTH-1:0] HRDATA,   // AHB Read Data
    output reg                 HRESP,     // AHB Response (OKAY = 0)
    output reg  [DATA_WIDTH-1:0] COUNTER   // Counter Output
);

  // Define the memory-mapped addresses.
  localparam [ADDR_WIDTH-1:0] ADDR_START   = 32'h00000000; // Write 1 to start/resume counter
  localparam [ADDR_WIDTH-1:0] ADDR_STOP    = 32'h00000004; // Write 1 to stop the counter
  localparam [ADDR_WIDTH-1:0] ADDR_COUNTER = 32'h00000008; // Read current counter value
  localparam [ADDR_WIDTH-1:0] ADDR_OVERFLOW= 32'h0000000C; // Read overflow flag
  localparam [ADDR_WIDTH-1:0] ADDR_MAXCNT  = 32'h00000010; // Write new maximum count value

  // Internal registers for control and configuration.
  reg                         enable;       // Counter enable signal
  reg                         overflow_flag;// Overflow flag (remains set until reset)
  reg [DATA_WIDTH-1:0]        max_cnt;      // Maximum count value for overflow condition

  // Synchronous logic: register updates, counter operations, and AHB interface handling.
  // Asynchronous reset: when HRESETn is low, all registers and the counter are reset to 0.
  always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
      enable            <= 1'b0;
      overflow_flag     <= 1'b0;
      COUNTER           <= {DATA_WIDTH{1'b0}};
      max_cnt           <= {DATA_WIDTH{1'b0}};
      HRESP             <= 1'b0;
    end
    else begin
      // Only process transactions when the slave is selected and ready.
      if (HSEL && HREADY) begin
        // Write operations.
        if (HWRITE) begin
          case (HADDR)
            ADDR_START:   if (HWDATA[0] == 1'b1) enable <= 1'b1;  // Start/resume counter
            ADDR_STOP:    if (HWDATA[0] == 1'b1) enable <= 1'b0;  // Stop counter
            ADDR_MAXCNT:  max_cnt <= HWDATA;                       // Configure maximum count value
            default:      ; // Ignore writes to undefined addresses.
          endcase
        end

        // Counter update (synchronous logic).
        // If the counter is enabled, increment it.
        // When the counter reaches the maximum count value, set the overflow flag and wrap around.
        if (enable) begin
          if (COUNTER == max_cnt) begin
            overflow_flag <= 1'b1;
            COUNTER       <= {DATA_WIDTH{1'b0}};
          end
          else begin
            COUNTER <= COUNTER + 1;
          end
        end
      end

      // Always indicate an OKAY response.
      HRESP <= 1'b0;
    end
  end

  // Combinational logic: Generate HRDATA based on the accessed address.
  always_comb begin
    // Default read data is zero.
    HRDATA = {DATA_WIDTH{1'b0}};
    if (HSEL && HREADY && !HWRITE) begin
      case (HADDR)
        ADDR_START:   HRDATA = 1'b0;  // Read returns 0 (no start command pending)
        ADDR_STOP:    HRDATA = 1'b0;  // Read returns 0 (no stop command pending)
        ADDR_COUNTER: HRDATA = COUNTER;
        ADDR_OVERFLOW: HRDATA = { {DATA_WIDTH-1{1'b0}}, overflow_flag };
        ADDR_MAXCNT:  HRDATA = max_cnt;
        default:      HRDATA = {DATA_WIDTH{1'b0}};
      endcase
    end
  end

endmodule