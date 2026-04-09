module axi_register #(parameter ADDR_WIDTH = 32, parameter DATA_WIDTH = 32) (
    input  logic clk_i,
    input  logic rst_n_i,
    // Write Address Channel
    input  logic [ADDR_WIDTH-1:0] awaddr_i,
    input  logic awvalid_i,
    output logic awready_o,
    // Write Data Channel
    input  logic [DATA_WIDTH-1:0] wdata_i,
    input  logic wvalid_i,
    input  logic [(DATA_WIDTH/8)-1:0] wstrb_i,
    output logic wready_o,
    // Write Response Channel
    output logic [1:0] bresp_o,
    output logic bvalid_o,
    input  logic bready_i,
    // Read Address Channel
    input  logic [ADDR_WIDTH-1:0] araddr_i,
    input  logic arvalid_i,
    output logic arready_o,
    // Read Data Channel
    output logic [DATA_WIDTH-1:0] rdata_o,
    output logic rvalid_o,
    output logic [1:0] rresp_o,
    // Register Outputs
    output logic [19:0] beat_o,
    output logic start_o,
    output logic writeback_o,
    // External hardware done signal
    input  logic done_i
);

  //-------------------------------------------------------------------------
  // Register Map Addresses and Fixed ID Value
  //-------------------------------------------------------------------------
  localparam logic [ADDR_WIDTH-1:0] BEAT_ADDR     = 32'h100;
  localparam logic [ADDR_WIDTH-1:0] START_ADDR    = 32'h200;
  localparam logic [ADDR_WIDTH-1:0] DONE_ADDR     = 32'h300;
  localparam logic [ADDR_WIDTH-1:0] WRITEBACK_ADDR= 32'h400;
  localparam logic [ADDR_WIDTH-1:0] ID_ADDR       = 32'h500;
  localparam logic [DATA_WIDTH-1:0] ID_VALUE      = 32'h00010001;

  //-------------------------------------------------------------------------
  // Internal Register Declarations
  //-------------------------------------------------------------------------
  logic [19:0] beat_reg;      // Beat counter register
  logic        start_reg;     // Start signal register
  logic        writeback_reg; // Writeback signal register
  logic        done_reg;      // Done status register (updated from done_i)

  //-------------------------------------------------------------------------
  // FSM State Declarations
  //-------------------------------------------------------------------------
  typedef enum logic [1:0] {
    WR_IDLE,
    WR_ADDR,
    WR_RESP
  } write_state_t;

  typedef enum logic [1:0] {
    RD_IDLE,
    RD_ADDR,
    RD_DATA
  } read_state_t;

  write_state_t write_state, write_state_next;
  read_state_t  read_state,  read_state_next;

  // Registers to capture the address during transactions
  logic [ADDR_WIDTH-1:0] write_addr_reg;
  logic [ADDR_WIDTH-1:0] read_addr_reg;

  // Determine if all byte enables are set (full write)
  logic full_write;
  assign full_write = (wstrb_i == {(DATA_WIDTH/8){1'b1}});

  //-------------------------------------------------------------------------
  // Output Assignments
  //-------------------------------------------------------------------------
  assign awready_o = (write_state == WR_IDLE);
  assign wready_o  = (write_state == WR_ADDR);
  assign arready_o = (read_state  == RD_IDLE);

  assign beat_o    = beat_reg;
  assign start_o   = start_reg;
  assign writeback_o = writeback_reg;

  //-------------------------------------------------------------------------
  // Write Address/Data FSM
  //-------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i)
      write_state <= WR_IDLE;
    else
      write_state <= write_state_next;
  end

  always_comb begin
    // Default next state remains the same
    write_state_next = write_state;
    // Default write response (OKAY by default)
    bresp_o = 2'b00;
    case (write_state)
      WR_IDLE: begin
        if (awvalid_i) begin
          write_addr_reg <= awaddr_i;
          write_state_next = WR_ADDR;
        end
      end
      WR_ADDR: begin
        if (wvalid_i) begin
          // If full write, update registers based on address
          if (full_write) begin
            case (write_addr_reg)
              BEAT_ADDR: begin
                // Update beat counter with lower 20 bits of wdata_i
                beat_reg <= wdata_i[19:0];
              end
              START_ADDR: begin
                // Update start signal: set to 1 if LSB is 1 and enabled by wstrb_i
                if (wdata_i[0] && wstrb_i[0])
                  start_reg <= 1'b1;
                else
                  start_reg <= start_reg;
              end
              DONE_ADDR: begin
                // Clear done status if LSB is 1
                if (wdata_i[0] && wstrb_i[0])
                  done_reg <= 1'b0;
                else
                  done_reg <= done_reg;
              end
              WRITEBACK_ADDR: begin
                if (wdata_i[0] && wstrb_i[0])
                  writeback_reg <= 1'b1;
                else
                  writeback_reg <= writeback_reg;
              end
              ID_ADDR: begin
                // Attempt to write to read-only ID register -> error response
                bresp_o = 2'b10; // SLVERR
              end
              default: begin
                // Invalid address -> error response
                bresp_o = 2'b10;
              end
            endcase
          end
          // Even for partial writes, complete the transaction
          write_state_next = WR_RESP;
        end
      end
      WR_RESP: begin
        if (bready_i)
          write_state_next = WR_IDLE;
      end
      default: write_state_next = WR_IDLE;
    endcase
  end

  // Generate write response valid signal
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i)
      bvalid_o <= 1'b0;
    else if (write_state == WR_RESP)
      bvalid_o <= 1'b1;
    else if (bready_i && write_state == WR_RESP)
      bvalid_o <= 1'b0;
  end

  //-------------------------------------------------------------------------
  // Read Address/Response FSM
  //-------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      read_state  <= RD_IDLE;
      read_addr_reg <= '0;
    end else begin
      read_state <= read_state_next;
    end
  end

  always_comb begin
    read_state_next = read_state;
    // Default read response (OKAY by default)
    rresp_o = 2'b00;
    rvalid_o = 1'b0;
    rdata_o  = {DATA_WIDTH{1'b0}};
    case (read_state)
      RD_IDLE: begin
        if (arvalid_i) begin
          read_addr_reg <= araddr_i;
          read_state_next = RD_ADDR;
        end
      end
      RD_ADDR: begin
        // Decode the read address and set the read data accordingly
        case (read_addr_reg)
          BEAT_ADDR: begin
            // Return beat counter padded to DATA_WIDTH
            rdata_o = { {(DATA_WIDTH-20){1'b0}}, beat_reg };
          end
          START_ADDR: begin
            rdata_o = { {(DATA_WIDTH-1){1'b0}}, start_reg };
          end
          DONE_ADDR: begin
            rdata_o = { {(DATA_WIDTH-1){1'b0}}, done_reg };
          end
          WRITEBACK_ADDR: begin
            rdata_o = { {(DATA_WIDTH-1){1'b0}}, writeback_reg };
          end
          ID_ADDR: begin
            rdata_o = ID_VALUE;
          end
          default: begin
            // Invalid address -> error response
            rresp_o = 2'b10;
          end
        endcase
        rvalid_o = 1'b1;
        read_state_next = RD_DATA;
      end
      RD_DATA: begin
        if (rready_i)
          read_state_next = RD_IDLE;
      end
      default: read_state_next = RD_IDLE;
    endcase
  end

  //-------------------------------------------------------------------------
  // Update Done Status Register from External Signal
  //-------------------------------------------------------------------------
  // The done_reg is updated externally from done_i unless cleared via a write.
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i)
      done_reg <= 1'b0;
    // If a write occurs to DONE_ADDR with full write and LSB==1, clear done_reg.
    else if (write_state == WR_ADDR && write_addr_reg == DONE_ADDR &&
             full_write && wdata_i[0] == 1'b1)
      done_reg <= 1'b0;
    // Otherwise, update done_reg with the external done_i signal.
    else if (done_i)
      done_reg <= 1'b1;
    // If a write occurs with LSB==0, leave done_reg unchanged.
    else
      done_reg <= done_reg;
  end

endmodule