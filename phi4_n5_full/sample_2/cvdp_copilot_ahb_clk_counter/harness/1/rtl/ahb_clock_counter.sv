module ahb_clock_counter #(
    parameter ADDR_WIDTH = 32, // Width of the address bus
    parameter DATA_WIDTH = 32  // Width of the data bus
)(
    input  wire                   HCLK,                       // AHB Clock
    input  wire                   HRESETn,                    // AHB Reset (Active Low)
    input  wire                   HSEL,                       // AHB Select
    input  wire [ADDR_WIDTH-1:0]  HADDR,                      // AHB Address
    input  wire                   HWRITE,                     // AHB Write Enable
    input  wire [DATA_WIDTH-1:0]  HWDATA,                     // AHB Write Data
    input  wire                   HREADY,                     // AHB Ready Signal
    output reg  [DATA_WIDTH-1:0]  HRDATA,                     // AHB Read Data
    output reg                   HRESP,                      // AHB Response (always OKAY = 0)
    output reg  [DATA_WIDTH-1:0]  COUNTER                     // Counter Output
);

  // Define register indices for the AHB mapped registers.
  // The registers are 4-byte aligned so we use bits [4:2] of HADDR.
  localparam START_INDEX   = 3'd0;
  localparam STOP_INDEX    = 3'd1;
  localparam COUNTER_INDEX = 3'd2;
  localparam OVERFLOW_INDEX= 3'd3;
  localparam MAXCNT_INDEX  = 3'd4;

  // Internal control registers.
  reg enable;                        // Counter enable signal.
  reg [DATA_WIDTH-1:0] max_count;     // Configurable maximum count value.
  reg overflow_flag;                 // Overflow flag (remains set until reset).

  //-------------------------------------------------------------------------
  // Synchronous process: Handle AHB transactions and counter update.
  //-------------------------------------------------------------------------
  always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
      // Asynchronous reset: clear all registers.
      enable            <= 1'b0;
      COUNTER           <= {DATA_WIDTH{1'b0}};
      max_count         <= {DATA_WIDTH{1'b0}};
      overflow_flag     <= 1'b0;
    end
    else begin
      //---------------------------------------------------------------
      // Handle AHB transactions if the slave is selected and ready.
      //---------------------------------------------------------------
      if (HSEL && HREADY) begin
        case (HADDR[4:2])
          START_INDEX: begin
            if (HWRITE)
              enable <= (HWDATA[0] ? 1'b1 : 1'b0);
          end
          STOP_INDEX: begin
            if (HWRITE)
              enable <= 1'b0;
          end
          MAXCNT_INDEX: begin
            if (HWRITE)
              max_count <= HWDATA;
          end
          default: ; // No action for unhandled addresses on write.
        endcase
      end

      //---------------------------------------------------------------
      // Counter update logic.
      // If enabled, increment the counter. When the counter reaches
      // (max_count - 1), roll over to 0 and set the overflow flag.
      //---------------------------------------------------------------
      if (enable) begin
        if (COUNTER == max_count - 1)
          COUNTER <= {DATA_WIDTH{1'b0}};
        else
          COUNTER <= COUNTER + 1;
      end

      // Set the overflow flag if the counter has just rolled over.
      if (enable && (COUNTER == max_count - 1))
        overflow_flag <= 1'b1;
    end
  end

  //-------------------------------------------------------------------------
  // Combinational process: Generate HRDATA based on HADDR.
  // For read transactions, return the appropriate register value.
  //-------------------------------------------------------------------------
  always @(*) begin
    // Default value for HRDATA.
    HRDATA = {DATA_WIDTH{1'b0}};
    if (HSEL && HREADY) begin
      case (HADDR[4:2])
        START_INDEX: begin
          // Read from START register returns 0.
          HRDATA = {DATA_WIDTH{1'b0}};
        end
        STOP_INDEX: begin
          // Read from STOP register returns 0.
          HRDATA = {DATA_WIDTH{1'b0}};
        end
        COUNTER_INDEX: begin
          HRDATA = COUNTER;
        end
        OVERFLOW_INDEX: begin
          // Return the overflow flag in the LSB and zeros in the rest.
          HRDATA = { {DATA_WIDTH-1{1'b0}}, overflow_flag };
        end
        MAXCNT_INDEX: begin
          HRDATA = max_count;
        end
        default: HRDATA = {DATA_WIDTH{1'b0}};
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Always indicate an OKAY response.
  //-------------------------------------------------------------------------
  always @(*) begin
    HRESP = 1'b0;
  end

endmodule