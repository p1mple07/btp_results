module load_store_unit (
  input  logic         clk,
  input  logic         rst_n,
  // Data-Cache Interface
  output logic         dmem_req_o,
  input  logic         dmem_gnt_i,
  output logic [31:0]  dmem_req_addr_o,
  output logic         dmem_req_we_o,
  output logic [3:0]   dmem_req_be_o,
  output logic [31:0]  dmem_req_wdata_o,
  input  logic         dmem_rvalid_i,
  input  logic [31:0]  dmem_rsp_rdata_i,
  // Execution Stage Interface
  input  logic         ex_if_req_i,
  input  logic         ex_if_we_i,
  input  logic [1:0]   ex_if_type_i,
  input  logic [31:0]  ex_if_wdata_i,
  input  logic [31:0]  ex_if_addr_base_i,
  input  logic [31:0]  ex_if_addr_offset_i,
  output logic         ex_if_ready_o,
  // Writeback Interface
  output logic [31:0]  wb_if_rdata_o,
  output logic         wb_if_rvalid_o
);

  //-------------------------------------------------------------------------
  // Combinational computation of effective address and byte enables
  //-------------------------------------------------------------------------
  logic [31:0] effective_addr;
  logic [3:0]  byte_en;
  logic        misaligned;

  // Calculate effective address as base + offset.
  assign effective_addr = ex_if_addr_base_i + ex_if_addr_offset_i;

  // Compute byte enable and misalignment flag based on data type.
  always_comb begin
    misaligned = 1'b0;
    case (ex_if_type_i)
      2'b00: begin
        // Byte access: no alignment requirement.
        byte_en = 1 << effective_addr[1:0];
      end
      2'b01: begin
        // Halfword access: effective address must be aligned to 2 bytes.
        if (effective_addr[1:0] != 2'b00 && effective_addr[1:0] != 2'b10)
          misaligned = 1'b1;
        else if (effective_addr[1:0] == 2'b00)
          byte_en = 4'b0011;  // Enable lower two bytes.
        else
          byte_en = 4'b1100;  // Enable upper two bytes.
      end
      2'b10: begin
        // Word access: effective address must be aligned to 4 bytes.
        if (effective_addr[1:0] != 2'b00)
          misaligned = 1'b1;
        else
          byte_en = 4'b1111;  // Enable all four bytes.
      end
      default: begin
        misaligned = 1'b1;
        byte_en = 4'b0000;
      end
    endcase
  end

  //-------------------------------------------------------------------------
  // Internal registers for transaction info and FSM state.
  //-------------------------------------------------------------------------
  // FSM state encoding.
  typedef enum logic [2:0] {
    IDLE      = 3'd0,
    START     = 3'd1,
    WAIT_GRANT = 3'd2,
    WAIT_RVALID = 3'd3,
    COMPLETE  = 3'd4
  } state_t;
  
  state_t state, next_state;

  // Registers to hold transaction info.
  logic [31:0] req_addr;
  logic [3:0]  req_be;
  logic        req_we;
  logic [31:0] req_wdata;
  // Register to latch load data from memory.
  logic [31:0] load_data;

  //-------------------------------------------------------------------------
  // FSM Sequential Logic
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state            <= IDLE;
      req_addr         <= 32'd0;
      req_be           <= 4'd0;
      req_we           <= 1'b0;
      req_wdata        <= 32'd0;
      load_data        <= 32'd0;
      // Clear all data-cache interface signals.
      dmem_req_addr_o  <= 32'd0;
      dmem_req_be_o    <= 4'd0;
      dmem_req_wdata_o <= 32'd0;
      // Clear writeback signals.
      wb_if_rdata_o    <= 32'd0;
      wb_if_rvalid_o   <= 1'b0;
      // Execution interface ready is high on reset.
      ex_if_ready_o    <= 1'b1;
    end
    else begin
      // Default assignments for data-cache interface signals.
      dmem_req_o       <= 1'b0;
      dmem_req_we_o    <= 1'b0;
      dmem_req_addr_o  <= 32'd0;
      dmem_req_be_o    <= 4'd0;
      dmem_req_wdata_o <= 32'd0;
      // Default: writeback signals are driven only in COMPLETE state.
      // ex_if_ready_o is high only in IDLE.
      ex_if_ready_o    <= (state == IDLE);

      case (state)
        IDLE: begin
          // Accept a new request if asserted, ready and access is aligned.
          if (ex_if_req_i && ex_if_ready_o && !misaligned) begin
            req_addr  <= effective_addr;
            req_be    <= byte_en;
            req_we    <= ex_if_we_i;
            req_wdata <= ex_if_wdata_i;
            state     <= START;
          end
        end

        START: begin
          // On the next cycle, assert the data-cache request signals.
          dmem_req_o        <= 1'b1;
          dmem_req_addr_o   <= req_addr;
          dmem_req_be_o     <= req_be;
          dmem_req_we_o     <= req_we;
          dmem_req_wdata_o  <= (req_we) ? req_wdata : 32'd0;
          state             <= WAIT_GRANT;
        end

        WAIT_GRANT: begin
          if (dmem_gnt_i) begin
            // Clear the request signals once the memory grants access.
            dmem_req_o        <= 1'b0;
            dmem_req_we_o     <= 1'b0;
            dmem_req_addr_o   <= 32'd0;
            dmem_req_be_o     <= 4'd0;
            dmem_req_wdata_o  <= 32'd0;
            // For store transactions, the transaction is complete.
            if (req_we)
              state <= COMPLETE;
            else
              state <= WAIT_RVALID;
          end
        end

        WAIT_RVALID: begin
          // For load transactions, wait for the valid data response.
          if (dmem_rvalid_i) begin
            load_data <= dmem_rsp_rdata_i;
            state     <= COMPLETE;
          end
        end

        COMPLETE: begin
          // In COMPLETE state, provide the read data to the writeback stage.
          // The response is valid for one cycle.
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Writeback Interface: Drive wb_if_rdata_o and wb_if_rvalid_o
  // The read data is available for one cycle when state is COMPLETE.
  //-------------------------------------------------------------------------
  assign wb_if_rdata_o = (state == COMPLETE) ? load_data : 32'd0;
  assign wb_if_rvalid_o = (state == COMPLETE) ? 1'b1 : 1'b0;

endmodule