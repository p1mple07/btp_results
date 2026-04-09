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
  input  logic [1:0]   ex_if_type_i,   // 2'b00: byte, 2'b01: halfword, 2'b10: word
  input  logic [31:0]  ex_if_wdata_i,
  input  logic [31:0]  ex_if_addr_base_i,
  input  logic [31:0]  ex_if_addr_offset_i,
  output logic         ex_if_ready_o,
  // Writeback Interface
  output logic [31:0]  wb_if_rdata_o,
  output logic         wb_if_rvalid_o
);

  //-------------------------------------------------------------------------
  // Combinational computation of effective address and request validity
  //-------------------------------------------------------------------------
  logic [31:0] effective_addr;
  assign effective_addr = ex_if_addr_base_i + ex_if_addr_offset_i;

  // Determine if the access is valid based on type and alignment.
  // Byte access: always valid.
  // Halfword access: valid if effective_addr[1:0] is 00 or 10.
  // Word access: valid if effective_addr[1:0] is 00.
  logic valid_req;
  assign valid_req = (ex_if_type_i == 2'b00) ||
                     ((ex_if_type_i == 2'b01) && ((effective_addr[1:0] == 2'b00) || (effective_addr[1:0] == 2'b10))) ||
                     ((ex_if_type_i == 2'b10) && (effective_addr[1:0] == 2'b00));

  //-------------------------------------------------------------------------
  // Internal registers to latch request parameters when a valid request is accepted.
  //-------------------------------------------------------------------------
  // req_type: 2'b00: byte, 2'b01: halfword, 2'b10: word
  logic [1:0] req_type;
  logic [31:0] req_addr;
  logic req_we;
  logic [31:0] req_wdata;

  //-------------------------------------------------------------------------
  // Combinational computation of byte enable based on access type and address.
  //-------------------------------------------------------------------------
  logic [3:0] byte_en;
  always_comb begin
    case (req_type)
      2'b00: begin
        // Byte access: enable only the byte corresponding to address[1:0]
        byte_en = 4'b0001 << req_addr[1:0];
      end
      2'b01: begin
        // Halfword access: enable two consecutive bytes.
        // If effective address LSBs == 00, enable lower two bytes (00-01);
        // if LSBs == 10, enable upper two bytes (10-11).
        if (req_addr[1:0] == 2'b00)
          byte_en = 4'b0011;
        else if (req_addr[1:0] == 2'b10)
          byte_en = 4'b1100;
        else
          byte_en = 4'b0000;  // Should not occur for valid request.
      end
      2'b10: begin
        // Word access: enable all four bytes.
        if (req_addr[1:0] == 2'b00)
          byte_en = 4'b1111;
        else
          byte_en = 4'b0000;
      end
      default: byte_en = 4'b0000;
    endcase
  end

  //-------------------------------------------------------------------------
  // FSM State Declaration
  //-------------------------------------------------------------------------
  typedef enum logic [2:0] {
    IDLE         = 3'd0,
    REQUEST      = 3'd1,
    WAIT_STORE   = 3'd2,
    WAIT_RVALID  = 3'd3,
    LOAD_RESP    = 3'd4
  } state_t;

  state_t state, next_state;

  //-------------------------------------------------------------------------
  // Main FSM: Controls LSU operation.
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
      req_type <= 2'b0;
      req_addr <= 32'd0;
      req_we   <= 1'b0;
      req_wdata<= 32'd0;
    end
    else begin
      case (state)
        IDLE: begin
          // LSU is ready to accept a new request.
          if (ex_if_req_i && valid_req) begin
            // Latch the request parameters.
            req_type <= ex_if_type_i;
            req_addr <= effective_addr;
            req_we   <= ex_if_we_i;
            req_wdata<= ex_if_wdata_i;
            state    <= REQUEST;
          end
          else begin
            state <= IDLE;
          end
        end

        REQUEST: begin
          // In this cycle, LSU outputs the transaction signals.
          // Transition based on whether it is a store (we) or load.
          if (req_we)
            state <= WAIT_STORE;
          else
            state <= WAIT_RVALID;
        end

        WAIT_STORE: begin
          // Wait for the data-cache to grant the store request.
          if (dmem_gnt_i) begin
            // Once granted, clear the dmem request signals (handled by output logic).
            state <= IDLE;
          end
        end

        WAIT_RVALID: begin
          // Wait for the data-cache to indicate that load data is valid.
          if (dmem_rvalid_i)
            state <= LOAD_RESP;
        end

        LOAD_RESP: begin
          // Drive the writeback interface for one cycle.
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Output Assignments
  //-------------------------------------------------------------------------
  // Execution stage ready signal: high only in IDLE.
  assign ex_if_ready_o = (state == IDLE);

  // Data-cache interface signals are driven only in the REQUEST state.
  assign dmem_req_o      = (state == REQUEST) ? 1'b1 : 1'b0;
  assign dmem_req_addr_o = (state == REQUEST) ? req_addr : 32'd0;
  assign dmem_req_we_o   = (state == REQUEST) ? req_we   : 1'b0;
  assign dmem_req_be_o   = (state == REQUEST) ? byte_en  : 4'd0;
  assign dmem_req_wdata_o= (state == REQUEST) ? req_wdata: 32'd0;

  // Writeback interface: valid and data are driven only during LOAD_RESP state.
  assign wb_if_rdata_o = (state == LOAD_RESP) ? dmem_rsp_rdata_i : 32'd0;
  assign wb_if_rvalid_o= (state == LOAD_RESP) ? 1'b1           : 1'b0;

endmodule