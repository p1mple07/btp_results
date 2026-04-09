rtl/wishbone_to_ahb_bridge.sv
------------------------------------------------------------
module wishbone_to_ahb_bridge (
  input  logic         clk_i,
  input  logic         rst_i,
  input  logic         cyc_i,
  input  logic         stb_i,
  input  logic [3:0]   sel_i,
  input  logic         we_i,
  input  logic [31:0]  addr_i,
  input  logic [31:0]  data_i,
  input  logic         hclk,
  input  logic         hreset_n,
  input  logic [31:0]  hrdata,
  input  logic [1:0]   hresp,
  input  logic         hready,
  output logic [31:0]  data_o,
  output logic         ack_o,
  output logic [1:0]   htrans,
  output logic [2:0]   hsize,
  output logic [2:0]   hburst,
  output logic         hwrite,
  output logic [31:0]  haddr,
  output logic [31:0]  hwdata
);

  //-------------------------------------------------------------------------
  // State encoding for FSM controlling AHB transaction phases.
  // AHB htrans: 00 = IDLE, 01 = NON-SEQUENTIAL, 10 = BUSY.
  //-------------------------------------------------------------------------
  localparam logic [1:0] STATE_IDLE     = 2'd0,
                         STATE_NON_SEQ  = 2'd1,
                         STATE_BUSY     = 2'd2;

  //-------------------------------------------------------------------------
  // Internal registers for FSM and computed signals.
  //-------------------------------------------------------------------------
  reg [1:0] state, next_state;

  // Variables to determine transfer size and byte offset.
  // count: number of bytes selected (valid values: 1, 2, or 4).
  reg [2:0] count;
  // offset: index (in bytes) of the lowest selected byte.
  reg [1:0] offset;
  // effective address: Wishbone address adjusted by the byte offset.
  reg [31:0] effective_addr;

  // Temporary register to pack selected bytes from data_i for write transactions.
  reg [31:0] write_data_packed;

  // Variables for read data conversion.
  reg [31:0] read_data_swapped;
  reg [31:0] selected_data;

  //-------------------------------------------------------------------------
  // Function: byte_swap
  // Description: Swaps the byte order of a 32-bit word.
  //-------------------------------------------------------------------------
  function automatic logic [31:0] byte_swap(input logic [31:0] data);
    begin
      byte_swap = { data[7:0], data[15:8], data[23:16], data[31:24] };
    end
  endfunction

  //-------------------------------------------------------------------------
  // FSM Sequential Process: State register update.
  // Synchronized to clk_i. Resets on rst_i (Wishbone reset) or hreset_n (AHB reset).
  //-------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_i or negedge hreset_n) begin
    if (!rst_i || !hreset_n)
      state <= STATE_IDLE;
    else
      state <= next_state;
  end

  //-------------------------------------------------------------------------
  // Combinational Process: Next state logic and signal assignments.
  //-------------------------------------------------------------------------
  always_comb begin
    // Default assignments for outputs.
    next_state   = state;
    htrans       = 2'b00;
    hsize        = 3'b000;
    hburst       = 3'b000;  // Always single transfer.
    hwrite       = 1'b0;
    haddr        = 32'd0;
    hwdata       = 32'd0;
    data_o       = 32'd0;
    ack_o        = 1'b0;

    //-------------------------------------------------------------------------
    // Determine transfer size and byte offset from sel_i.
    // Valid contiguous selections:
    //   4'b1111  -> 4 bytes, offset = 0.
    //