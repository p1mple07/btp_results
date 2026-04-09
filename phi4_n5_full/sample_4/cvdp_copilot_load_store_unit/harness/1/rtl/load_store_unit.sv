module load_store_unit (
  // Clock and Reset
  input  logic           clk,
  input  logic           rst_n,
  
  // Data-Cache Interface
  output logic           dmem_req_o,
  input  logic           dmem_gnt_i,
  output logic [31:0]    dmem_req_addr_o,
  output logic           dmem_req_we_o,
  output logic [3:0]     dmem_req_be_o,
  output logic [31:0]    dmem_req_wdata_o,
  input  logic           dmem_rvalid_i,
  input  logic [31:0]    dmem_rsp_rdata_i,
  
  // Execution Stage Interface
  input  logic           ex_if_req_i,
  input  logic           ex_if_we_i,
  input  logic [1:0]     ex_if_type_i, // 00: byte, 01: halfword, 10: word
  input  logic [31:0]    ex_if_wdata_i,
  input  logic [31:0]    ex_if_addr_base_i,
  input  logic [31:0]    ex_if_addr_offset_i,
  output logic           ex_if_ready_o,
  
  // Writeback Interface
  output logic [31:0]    wb_if_rdata_o,
  output logic           wb_if_rvalid_o
);

  //-------------------------------------------------------------------------
  // Internal Signals and State Declaration
  //-------------------------------------------------------------------------
  
  // FSM state encoding
  typedef enum logic [1:0] {
    STATE_IDLE      = 2'b00,
    STATE_WAIT_GRANT = 2'b01,
    STATE_WAIT_LOAD  = 2'b10
  } state_t;
  
  state_t state;
  
  // Internal registers to capture transaction information
  logic [31:0] req_addr;
  logic [31:0] req_wdata; // used for store transactions
  logic [3:0]  req_be;
  logic        is_load;   // 1 for load, 0 for store
  
  //-------------------------------------------------------------------------
  // Combinational: Effective Address and Alignment Check
  //-------------------------------------------------------------------------
  
  // Calculate effective address (base + offset)
  wire [31:0] effective_addr;
  assign effective_addr = ex_if_addr_base_i + ex_if_addr_offset_i;
  
  // Determine misalignment based on access type and effective address LSBs.
  // For byte access (type 00) no alignment is required.
  // For halfword access (type 01), effective_addr[1:0] must be 00 or 10.
  // For word access (type 10), effective_addr[1:0] must be 00.
  wire misaligned;
  assign misaligned = (ex_if_type_i == 2'b01 && !(effective_addr[1:0] == 2'b00 || effective_addr[1:0] == 2'b10))
                      || (ex_if_type_i == 2'b10 && effective_addr[1:0] != 2'b00);
  
  //-------------------------------------------------------------------------
  // Combinational: Compute Byte Enable (BE) Mask
  //-------------------------------------------------------------------------
  
  // For byte access, enable the single byte corresponding to effective_addr[1:0].
  // For halfword access, enable two consecutive bytes:
  //   - LSB 00 selects bytes 0 and 1.
  //   - LSB 10 selects bytes 2 and 3.
  // For word access, enable all four bytes if aligned.
  logic [3:0] byte_en;
  always_comb begin
    case (ex_if_type_i)
      2'b00: begin
        // Byte access: enable single byte based on effective address LSBs.
        unique case (effective_addr[1:0])
          2'b00: byte_en = 4'b0001;
          2'b01: byte_en = 4'b0010;
          2'b10: byte_en = 4'b0100;
          2'b11: byte_en = 4'b1000;
        endcase
      end
      2'b01: begin
        // Halfword access: enable two consecutive bytes.
        if (effective_addr[1:0] == 2'b00) begin
          byte_en = 4'b0011;
        end else if (effective_addr[1:0] == 2'b10) begin
          byte_en = 4'b1100;
        end else begin
          byte_en = 4'b0000; // Misaligned access: BE not used.
        end
      end
      2'b10: begin
        // Word access: enable all bytes if aligned.
        if (effective_addr[1:0] == 2'b00) begin
          byte_en = 4'b1111;
        end else begin
          byte_en = 4'b0000;
        end
      end
      default: byte_en = 4'b0000;
    endcase
  end
  
  //-------------------------------------------------------------------------
  // FSM Sequential Process: Handling Requests and Transactions
  //-------------------------------------------------------------------------
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state           <= STATE_IDLE;
      req_addr        <= 32'b0;
      req_wdata       <= 32'b0;
      req_be          <= 4'b0;
      is_load         <= 1'b1; // Default value (unused in IDLE)
    end
    else begin
      case (state)
        STATE_IDLE: begin
          // In IDLE, LSU is ready to accept a new request.
          // Accept the request if ex_if_req_i is asserted and the access is aligned.
          if (ex_if_req_i && !misaligned) begin
            req_addr <= effective_addr;
            req_be   <= byte_en;
            if (ex_if_we_i) begin
              // Store transaction
              req_wdata <= ex_if_wdata_i;
              is_load   <= 1'b0;
            end
            else begin
              // Load transaction
              is_load <= 1'b1;
            end
            state <= STATE_WAIT_GRANT;
          end
        end
        
        STATE_WAIT_GRANT: begin
          // Drive the data cache interface signals with the captured transaction info.
          // Wait until the data cache grants the request.
          if (dmem_gnt_i) begin
            // For store transactions, transaction completes immediately.
            // For load transactions, transition to WAIT_LOAD to capture the read data.
            state <= (is_load) ? STATE_WAIT_LOAD : STATE_IDLE;
          end
        end
        
        STATE_WAIT_LOAD: begin
          // For load transactions, wait for the data cache to assert dmem_rvalid_i.
          if (dmem_rvalid_i) begin
            state <= STATE_IDLE;
          end
        end
        
        default: state <= STATE_IDLE;
      endcase
    end
  end
  
  //-------------------------------------------------------------------------
  // Combinational: Output Assignments
  //-------------------------------------------------------------------------
  
  // Execution stage ready signal: LSU is ready in IDLE state.
  assign ex_if_ready_o = (state == STATE_IDLE);
  
  // Data-cache interface signals and writeback interface signals.
  always_comb begin
    // Default outputs
    dmem_req_o         = 1'b0;
    dmem_req_addr_o    = 32'b0;
    dmem_req_we_o      = 1'b0;
    dmem_req_be_o      = 4'b0;
    dmem_req_wdata_o   = 32'b0;
    wb_if_rdata_o      = 32'b0;
    wb_if_rvalid_o     = 1'b0;
    
    case (state)
      STATE_WAIT_GRANT: begin
        // Initiate the data cache transaction.
        dmem_req_o         = 1'b1;
        dmem_req_addr_o    = req_addr;
        // For load transactions, write enable is deasserted.
        dmem_req_we_o      = (is_load) ? 1'b0 : 1'b1;
        dmem_req_be_o      = req_be;
        if (!is_load) begin
          dmem_req_wdata_o = req_wdata;
        end
      end
      
      STATE_WAIT_LOAD: begin
        // For load transactions, when the data cache asserts dmem_rvalid_i,
        // capture the read data and assert the writeback valid signal.
        if (dmem_rvalid_i) begin
          wb_if_rdata_o    = dmem_rsp_rdata_i;
          wb_if_rvalid_o   = 1'b1;
        end
      end
    endcase
  end
  
endmodule