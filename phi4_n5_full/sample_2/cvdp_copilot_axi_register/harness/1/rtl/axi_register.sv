// File: rtl/axi_register.sv
module axi_register #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
)(
  input  logic                   clk_i,
  input  logic                   rst_n_i,
  // Write Address Channel
  input  logic [ADDR_WIDTH-1:0]  awaddr_i,
  input  logic                   awvalid_i,
  output logic                   awready_o,
  // Write Data Channel
  input  logic [DATA_WIDTH-1:0]  wdata_i,
  input  logic                   wvalid_i,
  input  logic [(DATA_WIDTH/8)-1:0] wstrb_i,
  output logic                   wready_o,
  // Write Response Channel
  output logic [1:0]             bresp_o,
  output logic                   bvalid_o,
  input  logic                   bready_i,
  // Read Address Channel
  input  logic [ADDR_WIDTH-1:0]  araddr_i,
  input  logic                   arvalid_i,
  output logic                   arready_o,
  // Read Data Channel
  output logic [DATA_WIDTH-1:0]  rdata_o,
  output logic                   rvalid_o,
  input  logic                   rready_i,
  // External done signal (to be reflected in the Done register)
  input  logic                   done_i,
  // Register outputs
  output logic [19:0]            beat_o,
  output logic                   start_o,
  output logic                   writeback_o
);

  //-------------------------------------------------------------------------
  // Internal registers for the accessible hardware registers
  //-------------------------------------------------------------------------
  logic [19:0] beat_reg;
  logic        start_reg;
  logic        done_reg;         // Internal copy of the Done status
  logic        writeback_reg;
  logic [31:0] id_reg;           // Fixed identification register

  //-------------------------------------------------------------------------
  // Local parameters for register addresses (word addresses)
  // The offsets in the specification (0x100, 0x200, etc.) are divided by 4.
  //-------------------------------------------------------------------------
  localparam [ADDR_WIDTH-1:0] ADDR_BEAT   = { {(ADDR_WIDTH-2){1'b0}}, 16'h40 };  // 0x100 >> 2 = 0x40
  localparam [ADDR_WIDTH-1:0] ADDR_START  = { {(ADDR_WIDTH-2){1'b0}}, 16'h80 };  // 0x200 >> 2 = 0x80
  localparam [ADDR_WIDTH-1:0] ADDR_DONE   = { {(ADDR_WIDTH-2){1'b0}}, 16'hC0 };  // 0x300 >> 2 = 0xC0
  localparam [ADDR_WIDTH-1:0] ADDR_WB     = { {(ADDR_WIDTH-2){1'b0}}, 16'h100 }; // 0x400 >> 2 = 0x100
  localparam [ADDR_WIDTH-1:0] ADDR_ID     = { {(ADDR_WIDTH-2){1'b0}}, 16'h140 }; // 0x500 >> 2 = 0x140

  //-------------------------------------------------------------------------
  // AXI4-Lite Write Transaction FSM
  //-------------------------------------------------------------------------
  typedef enum logic [1:0] {
    W_IDLE = 2'd0,
    W_ADDR = 2'd1,
    W_DATA = 2'd2,
    W_RESP = 2'd3
  } write_state_t;

  write_state_t write_state, write_state_next;

  // Registers to hold captured write address and data
  logic [ADDR_WIDTH-1:0] write_addr_reg;
  logic [DATA_WIDTH-1:0] write_data_reg;
  logic [(DATA_WIDTH/8)-1:0] write_strobe_reg;

  // Response codes
  localparam OKAY   = 2'b00;
  localparam SLVERR = 2'b10;

  // Write FSM sequential block
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      write_state       <= W_IDLE;
      write_addr_reg    <= '0;
      write_data_reg    <= '0;
      write_strobe_reg  <= '0;
      bvalid_o          <= 1'b0;
      bresp_o           <= OKAY;
    end
    else begin
      write_state <= write_state_next;
      // Default: deassert response valid
      bvalid_o <= 1'b0;
      bresp_o  <= OKAY;
      // Capture write data in W_ADDR state
      if (write_state == W_ADDR && wvalid_i) begin
        write_data_reg    <= wdata_i;
        write_strobe_reg  <= wstrb_i;
      end
    end
  end

  // Write FSM next-state logic
  always_comb begin
    write_state_next = write_state;
    awready_o = 1'b0;
    wready_o  = 1'b0;
    bvalid_o  = 1'b0;
    bresp_o   = OKAY;
    case (write_state)
      W_IDLE: begin
        if (awvalid_i) begin
          write_state_next = W_ADDR;
          awready_o = 1'b1;
        end
      end
      W_ADDR: begin
        if (wvalid_i) begin
          write_state_next = W_DATA;
          wready_o = 1'b1;
        end
      end
      W_DATA: begin
        // Check for full write: all byte enables must be asserted.
        logic full_write;
        full_write = (write_strobe_reg == { (DATA_WIDTH/8){1'b1} });
        logic error;
        error = 1'b0;
        // Decode target register based on captured address
        if (write_addr_reg == ADDR_ID) begin
          // Attempt to write to the read-only ID register generates an error.
          error = 1'b1;
        end
        // Update registers only on a full write; partial writes are acknowledged without update.
        if (full_write) begin
          case (