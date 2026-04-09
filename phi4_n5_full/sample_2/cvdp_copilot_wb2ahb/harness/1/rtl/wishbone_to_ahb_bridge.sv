module wishbone_to_ahb_bridge (
  input  wire         clk_i,       // Wishbone clock
  input  wire         rst_i,       // Active-low Wishbone reset
  input  wire         cyc_i,       // Wishbone cycle valid
  input  wire         stb_i,       // Wishbone strobe valid
  input  wire [3:0]   sel_i,       // Wishbone byte enables
  input  wire         we_i,        // Wishbone write enable
  input  wire [31:0]  addr_i,      // Wishbone address
  input  wire [31:0]  data_i,      // Wishbone write data
  input  wire         hclk,        // AHB clock (assumed same as clk_i for simplicity)
  input  wire         hreset_n,    // Active-low AHB reset
  input  wire [31:0]  hrdata,      // AHB read data
  input  wire [1:0]   hresp,       // AHB response
  input  wire         hready,      // AHB slave ready signal
  output reg  [31:0]  data_o,      // Wishbone read data
  output reg          ack_o,       // Wishbone acknowledge
  output reg [1:0]    htrans,      // AHB transaction type
  output reg [2:0]    hsize,       // AHB transfer size
  output reg [2:0]    hburst,      // AHB burst type (SINGLE only)
  output reg          hwrite,      // AHB write enable
  output reg [31:0]   haddr,       // AHB address
  output reg [31:0]   hwdata       // AHB write data
);

  //-------------------------------------------------------------------------
  // State Encoding for the Wishbone-to-AHB bridge FSM
  //-------------------------------------------------------------------------
  typedef enum logic [1:0] {
    IDLE = 2'b00,
    WAIT = 2'b01
  } state_t;
  
  state_t state, next_state;

  // Internal registers to latch Wishbone transaction parameters
  reg [31:0] latched_addr;
  reg [31:0] latched_data;
  reg [3:0]  latched_sel;
  reg        latched_we;
  reg [2:0]  latched_hsize;  // Computed based on sel_i

  //-------------------------------------------------------------------------
  // FSM: Manages the protocol translation and pipelining of AHB transactions.
  // In IDLE state, the bridge waits for a valid Wishbone transaction (cyc_i & stb_i).
  // Upon detection, it latches the transaction parameters, computes the aligned
  // AHB address and transfer size, performs endian conversion on the write data,
  // and drives the AHB interface signals.
  // In the WAIT state, the bridge holds the AHB signals until the AHB slave asserts
  // hready. Once hready is seen, for read transactions the hrdata is converted back,
  // and ack_o is asserted to complete the Wishbone transaction.
  //-------------------------------------------------------------------------
  always @(posedge clk_i or negedge rst_i) begin
    if (!rst_i) begin
      state         <= IDLE;
      ack_o         <= 1'b0;
      htrans        <= 2'b00;
      hburst        <= 3'b000;
      haddr         <= 32'd0;
      hwdata        <= 32'd0;
      hwrite        <= 1'b0;
      hsize         <= 3'b000;
      data_o        <= 32'd0;
    end
    else begin
      case (state)
        IDLE: begin
          ack_o         <= 1'b0;
          // Clear AHB signals when idle
          htrans        <= 2'b00;
          hburst        <= 3'b000;
          haddr         <= 32'd0;
          hwdata        <= 32'd0;
          hwrite        <= 1'b0;
          hsize         <= 3'b000;
          data_o        <= 32'd0;
          
          // Detect a valid Wishbone transaction
          if (cyc_i && stb_i) begin
            // Latch Wishbone transaction parameters
            latched_addr  <= addr_i;
            latched_data  <= data_i;
            latched_sel   <= sel_i;
            latched_we    <= we_i;
            
            // Determine AHB transfer size based on sel_i:
            //  - 4'b1111: Full word transfer (size = 3'b011)
            //  - 4'b0011: Halfword transfer (size = 3'b010)
            //  - 4'b0001: Byte transfer (size = 3'b001)
            // For any other sel_i value, default to word transfer.
            case (latched_sel)
              4'b1111: latched_hsize <= 3'b011;
              4'b0011: latched_hsize <= 3'b010;
              4'b0001: latched_hsize <= 3'b001;
              default: latched_hsize <= 3'b011;
            endcase

            // Drive AHB transaction signals:
            // Set htrans to NON_SEQ (2'b10) to indicate address phase.
            htrans        <= 2'b10;
            // hburst is always SINGLE (3'b000).
            hburst        <= 3'b000;
            // Align the AHB address based on the transfer size.
            case (latched_sel)
              4'b1111: haddr <= latched_addr;
              4'b0011: haddr <= latched_addr & 32'hFFFFFFFC;
              4'b0001: haddr <= latched_addr & 32'hFFFFFFF8;
              default: haddr <= latched_addr;
            endcase
            // Drive the write enable.
            hwrite        <= latched_we;
            // Perform endian conversion: convert Wishbone little-endian data
            // to AHB big-endian format.
            hwdata        <= { latched_data[7:0],
                                latched_data[15:8],
                                latched_data[23:16],
                                latched_data[31:24] };
            // Transition to WAIT state to await AHB slave readiness.
            state         <= WAIT;
          end
        end

        WAIT: begin
          // Hold AHB signals until hready is asserted.
          if (hready) begin
            // For read transactions, perform endian conversion on hrdata.
            if (!latched_we) begin
              data_o <= { hrdata[7:0],
                          hrdata[15:8],
                          hrdata[23:16],
                          hrdata[31:24] };
            end
            // Assert ack_o to signal completion of the Wishbone transaction.
            ack_o <= 1'b1;
            // Clear AHB signals after transaction completion.
            htrans        <= 2'b00;
            hburst        <= 3'b000;
            haddr         <= 32'd0;
            hwdata        <= 32'd0;
            hwrite        <= 1'b0;
            // Pass the computed transfer size to hsize.
            hsize         <= latched_hsize;
            // Return to IDLE state.
            state         <= IDLE;
          end
          else begin
            // Maintain AHB signals while waiting.
            htrans        <= 2'b10;
            hburst        <= 3'b000;
            // haddr, hwdata, and hwrite remain as latched.
          end
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule