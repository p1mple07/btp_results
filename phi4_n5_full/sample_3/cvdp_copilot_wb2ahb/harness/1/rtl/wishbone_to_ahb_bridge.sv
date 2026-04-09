module wishbone_to_ahb_bridge (
  // Wishbone Ports (from WB Master)
  input  logic         clk_i,
  input  logic         rst_i,
  input  logic         cyc_i,
  input  logic         stb_i,
  input  logic [3:0]   sel_i,
  input  logic         we_i,
  input  logic [31:0]  addr_i,
  input  logic [31:0]  data_i,
  
  // AHB Ports (from AHB Slave)
  input  logic         hclk,
  input  logic         hreset_n,
  input  logic [31:0]  hrdata,
  input  logic [1:0]   hresp,
  
  // Wishbone Outputs
  output logic [31:0]  data_o,
  output logic         ack_o,
  
  // AHB Outputs
  output logic [1:0]   htrans,
  output logic [2:0]   hsize,
  output logic [2:0]   hburst,
  output logic         hwrite,
  output logic [31:0]  haddr,
  output logic [31:0]  hwdata
);

  //-------------------------------------------------------------------------
  // Internal Functions: Calculate Transfer Size and Byte Count
  //-------------------------------------------------------------------------
  // Function to calculate the transfer size (in bytes) based on sel_i.
  // Assumes contiguous selection starting from LSB.
  function automatic int calc_bytes (input logic [3:0] sel);
    if (sel[0]) begin
      if (sel[1]) begin
        if (sel[2]) begin
          if (sel[3])
            return 4;  // Word transfer
          else
            return 4;  // For simplicity, treat as word if non-contiguous upper nibble
        end else begin
          return 2;  // Halfword transfer
        end
      end else begin
        return 1;  // Byte transfer
      end
    end
    return 1; // Default to 1 byte if no LSB selected
  endfunction

  // Function to calculate AHB hsize signal based on transfer size.
  // AHB hsize: 3'b000 = byte, 3'b001 = halfword, 3'b010 = word.
  function automatic logic [2:0] calc_hsize (input logic [3:0] sel);
    int bytes;
    bytes = calc_bytes(sel);
    if (bytes == 4)
      return 3'b010; // Word
    else if (bytes == 2)
      return 3'b001; // Halfword
    else
      return 3'b000; // Byte
  endfunction

  // Function to perform endian conversion (byte swap).
  function automatic logic [31:0] swap_endian (input logic [31:0] data);
    return { data[7:0], data[15:8], data[23:16], data[31:24] };
  endfunction

  //-------------------------------------------------------------------------
  // Internal Registers and State Machine
  //-------------------------------------------------------------------------
  typedef enum logic [1:0] {
    IDLE    = 2'b00,
    NONSEQ  = 2'b01,
    BUSY    = 2'b10
  } state_t;

  state_t state, next_state;

  // Registers to hold transaction attributes for AHB phase.
  logic [31:0] haddr_reg;
  logic [2:0]  hsize_reg;
  logic        hwrite_reg;
  logic [31:0] hwdata_reg;

  // Register to capture Wishbone transaction info.
  logic [31:0] wb_addr_reg;
  logic [31:0] wb_data_reg;
  logic [3:0]  wb_sel_reg;
  logic        wb_we_reg;

  // FSM next state logic
  always_comb begin
    next_state = state;
    // Default outputs for AHB signals in combinational block.
    htrans      = 2'b00; // Default IDLE
    hburst      = 3'b000; // Always SINGLE transfer
    hwrite      = 1'b0;
    haddr       = 32'h0;
    hwdata      = 32'h0;
    ack_o       = 1'b0;
    data_o      = 32'h0;

    case (state)
      IDLE: begin
        // On valid Wishbone transaction, capture inputs and move to NONSEQ.
        if (cyc_i && stb_i) begin
          wb_addr_reg  = addr_i;
          wb_data_reg  = data_i;
          wb_sel_reg   = sel_i;
          wb_we_reg    = we_i;
          next_state   = NONSEQ;
        end
      end

      NONSEQ: begin
        // Latch transaction attributes for AHB phase.
        haddr_reg   = wb_addr_reg & (~({32{calc_bytes(wb_sel_reg)-1}})); // Align address to transfer size
        hsize_reg   = calc_hsize(wb_sel_reg);
        hwrite_reg  = wb_we_reg;
        hwdata_reg  = wb_we_reg ? swap_endian(wb_data_reg) : 32'h0;
        // Issue NONSEQ phase.
        htrans      = 2'b01;
        haddr       = haddr_reg;
        hsize       = hsize_reg;
        hburst      = 3'b000;
        hwrite      = hwrite_reg;
        hwdata      = hwdata_reg;
        next_state  = BUSY;
      end

      BUSY: begin
        // Hold transaction attributes until AHB slave is ready.
        htrans      = 2'b10;
        haddr       = haddr_reg;
        hsize       = hsize_reg;
        hburst      = 3'b000;
        hwrite      = hwrite_reg;
        hwdata      = hwdata_reg;
        // Once hready is asserted, complete the transaction.
        if (hready) begin
          // Endian convert read data from AHB to Wishbone.
          data_o = swap_endian(hrdata);
          ack_o  = 1'b1;
          next_state = IDLE;
        end
      end

      default: next_state = IDLE;
    endcase
  end

  // Synchronize state and transaction attributes.
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  // Note: In a real design, separate clock domains for clk_i and hclk would require
  // proper synchronization. For simplicity, this example assumes a single clock domain.

endmodule