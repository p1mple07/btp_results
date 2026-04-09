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
  output logic                   wready_o,
  input  logic [(DATA_WIDTH/8)-1:0] wstrb_i,
  output logic [1:0]             bresp_o,
  input  logic                   bready_i,
  // Read Address Channel
  input  logic [ADDR_WIDTH-1:0]  araddr_i,
  input  logic                   arvalid_i,
  output logic                   arready_o,
  // Read Data Channel
  output logic [DATA_WIDTH-1:0]  rdata_o,
  output logic                   rvalid_o,
  output logic [1:0]             rresp_o,
  // Register outputs
  output logic [19:0]            beat_o,
  output logic                   start_o,
  output logic                   writeback_o,
  // External done signal for Done register update
  input  logic                   done_i
);

  //-------------------------------------------------------------------------
  // Local Parameters and Constants
  //-------------------------------------------------------------------------
  localparam OKAY   = 2'b00;
  localparam SLVERR = 2'b10;

  // Register Map Addresses
  localparam BEAT_ADDR    = 32'h100;
  localparam START_ADDR   = 32'h200;
  localparam DONE_ADDR    = 32'h300;
  localparam WRITEBACK_ADDR = 32'h400;
  localparam ID_ADDR      = 32'h500;

  //-------------------------------------------------------------------------
  // State Machine Types for Write and Read Transactions
  //-------------------------------------------------------------------------
  typedef enum logic [1:0] {
    W_IDLE,
    W_ADDR,
    W_DATA,
    W_RESP
  } write_state_t;

  typedef enum logic [1:0] {
    R_IDLE,
    R_ADDR,
    R_DATA
  } read_state_t;

  //-------------------------------------------------------------------------
  // Internal Registers for AXI Handshake
  //-------------------------------------------------------------------------
  // Write transaction registers
  reg [ADDR_WIDTH-1:0] awaddr_reg;
  reg [DATA_WIDTH-1:0] wdata_reg;
  reg [(DATA_WIDTH/8)-1:0] wstrb_reg;

  // Internal registers for our hardware registers
  reg [19:0] beat_reg;
  reg        start_reg;
  reg        writeback_reg;
  reg        done_reg;

  //-------------------------------------------------------------------------
  // Output Assignments for Register Outputs
  //-------------------------------------------------------------------------
  assign beat_o       = beat_reg;
  assign start_o      = start_reg;
  assign writeback_o  = writeback_reg;

  //-------------------------------------------------------------------------
  // Write Address Channel FSM
  //-------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      awaddr_reg <= '0;
    end else begin
      case (write_state)
        W_IDLE: begin
          if (awvalid_i)
            awaddr_reg <= awaddr_i;
        end
        default: ;
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Write Data Channel FSM
  //-------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      wdata_reg  <= '0;
      wstrb_reg  <= '0;
    end else begin
      case (write_state)
        W_ADDR: begin
          if (wvalid_i) begin
            wdata_reg  <= wdata_i;
            wstrb_reg  <= wstrb_i;
          end
        end
        default: ;
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Write FSM State Register
  //-------------------------------------------------------------------------
  reg write_state_t write_state;
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i)
      write_state <= W_IDLE;
    else begin
      case (write_state)
        W_IDLE: begin
          if (awvalid_i)
            write_state <= W_ADDR;
        end
        W_ADDR: begin
          if (wvalid_i)
            write_state <= W_DATA;
        end
        W_DATA: begin
          write_state <= W_RESP;
        end
        W_RESP: begin
          if (bready_i)
            write_state <= W_IDLE;
        end
        default: write_state <= W_IDLE;
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Write Ready Signals
  //-------------------------------------------------------------------------
  // awready_o is asserted in W_IDLE state.
  always_comb begin
    awready_o = (write_state == W_IDLE);
  end

  // wready_o is asserted in W_DATA state.
  always_comb begin
    wready_o = (write_state == W_DATA);
  end

  //-------------------------------------------------------------------------
  // Write Response Generation
  //-------------------------------------------------------------------------
  reg bvalid_reg;
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      bvalid_reg  <= 1'b0;
      bresp_o     <= 2'b00;
    end else begin
      if (write_state == W_RESP) begin
        // Validate the address and strobe conditions.
        if ((awaddr_reg == BEAT_ADDR) ||
            (awaddr_reg == START_ADDR) ||
            (awaddr_reg == DONE_ADDR) ||
            (awaddr_reg == WRITEBACK_ADDR) ||
            (awaddr_reg == ID_ADDR))
        begin
          // Writing to the ID register is not allowed.
          if (awaddr_reg == ID_ADDR)
            bresp_o <= SLVERR;
          else
            bresp_o <= OKAY;
        end else begin
          bresp_o <= SLVERR;
        end
        bvalid_reg <= 1'b1;
      end else begin
        bvalid_reg <= 1'b0;
      end
    end
  end
  assign bvalid_o = bvalid_reg;

  //-------------------------------------------------------------------------
  // Register Update Logic on Write Data Acceptance
  //-------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      beat_reg      <= 20'd0;
      start_reg     <= 1'b0;
      writeback_reg <= 1'b0;
      done_reg      <= 1'b0;
    end else begin
      // Only update registers during the W_DATA state.
      if (write_state == W_DATA) begin
        case (awaddr_reg)
          BEAT_ADDR: begin
            // For the 20-bit Beat counter, require a full write:
            // wstrb_reg[3] must be asserted and lower three bytes enabled.
            if (wstrb_reg[3] && (wstrb_reg[2:0] == 3'b111))
              beat_reg <= wdata_reg[19:0];
          end
          START_ADDR: begin
            // Update Start signal if byte enable is valid.
            if (wstrb_reg[0])
              start_reg <= wdata_reg[0];
          end
          DONE_ADDR: begin
            // Clear Done register if LSB is 1.
            if (wstrb_reg[0] && wdata_reg[0])
              done_reg <= 1'b0;
          end
          WRITEBACK_ADDR: begin
            // Update Writeback signal if byte enable is valid.
            if (wstrb_reg[0])
              writeback_reg <= wdata_reg[0];
          end
          ID_ADDR: begin
            // No update for the read-only ID register.
          end
          default: ;
        endcase
      end
      // When not in a write transaction, update the Done register from the external done_i.
      else if (write_state == W_IDLE) begin
        done_reg <= done_i;
      end
    end
  end

  //-------------------------------------------------------------------------
  // Read Address Channel FSM
  //-------------------------------------------------------------------------
  reg read_state_t read_state;
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i)
      read_state <= R_IDLE;
    else begin
      case (read_state)
        R_IDLE: begin
          if (arvalid_i)
            read_state <= R_ADDR;
        end
        R_ADDR: begin
          if (rready_i)
            read_state <= R_IDLE;
        end
        default: read_state <= R_IDLE;
      endcase
    end
  end

  // arready_o is asserted in R_IDLE state.
  always_comb begin
    arready_o = (read_state == R_IDLE);
  end

  //-------------------------------------------------------------------------
  // Read Data Generation
  //-------------------------------------------------------------------------
  reg rvalid_reg;
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      rdata_o   <= '0;
      rvalid_reg <= 1'b0;
      rresp_o   <= 2'b00;
    end else begin
      if (read_state == R_ADDR) begin
        case (araddr_i)
          BEAT_ADDR: begin
            // Pad the 20-bit beat counter to DATA_WIDTH.
            rdata_o <= { {(DATA_WIDTH-20){1'b0}}, beat_reg };
            rresp_o <= OKAY;
          end
          START_ADDR: begin
            rdata_o <= { {DATA_WIDTH{start_reg}} };
            rresp_o <= OKAY;
          end
          DONE_ADDR: begin
            rdata_o <= { {DATA_WIDTH{done_reg}} };
            rresp_o <= OKAY;
          end
          WRITEBACK_ADDR: begin
            rdata_o <= { {DATA_WIDTH{writeback_reg}} };
            rresp_o <= OKAY;
          end
          ID_ADDR: begin
            rdata_o <= 32'h00010001;
            rresp_o <= OKAY;
          end
          default: begin
            rdata_o <= '0;
            rresp_o <= SLVERR;
          end
        endcase
        rvalid_reg <= 1'b1;
      end else begin
        rvalid_reg <= 1'b0;
      end
    end
  end
  assign rvalid_o = rvalid_reg;

endmodule