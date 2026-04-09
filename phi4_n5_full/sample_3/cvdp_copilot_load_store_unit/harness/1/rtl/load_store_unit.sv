module load_store_unit (
  input  wire         clk,
  input  wire         rst_n,
  // Data-Cache Interface
  output reg          dmem_req_o,
  input  wire         dmem_gnt_i,
  output reg [31:0]   dmem_req_addr_o,
  output reg          dmem_req_we_o,
  output reg [3:0]    dmem_req_be_o,
  output reg [31:0]   dmem_req_wdata_o,
  input  wire         dmem_rvalid_i,
  input  wire [31:0]  dmem_rsp_rdata_i,
  // Execution Stage Interface
  input  wire         ex_if_req_i,
  input  wire         ex_if_we_i,
  input  wire [1:0]   ex_if_type_i,
  input  wire [31:0]  ex_if_wdata_i,
  input  wire [31:0]  ex_if_addr_base_i,
  input  wire [31:0]  ex_if_addr_offset_i,
  output reg          ex_if_ready_o,
  // Writeback Interface
  output reg [31:0]   wb_if_rdata_o,
  output reg          wb_if_rvalid_o
);

  // State encoding
  localparam IDLE      = 2'b00,
             SENT      = 2'b01,
             WAIT_LOAD = 2'b10;

  // Internal registers to hold latched request information
  reg [1:0] state;
  reg [31:0] eff_addr_reg;       // Latched effective address
  reg [1:0]  type_reg;           // Latched data type
  reg        is_store_reg;       // Latched store flag (1 = store, 0 = load)
  reg [31:0] req_wdata_reg;      // Latched write data (for store)
  reg [3:0]  be_mask_reg;        // Computed byte enable mask
  reg [31:0] rdata_reg;          // Latched read data (for load)

  // Compute effective address (combinationally)
  wire [31:0] eff_addr;
  assign eff_addr = ex_if_addr_base_i + ex_if_addr_offset_i;

  // Alignment check based on data type and effective address.
  // For byte access (ex_if_type_i == 2'b00): always valid.
  // For halfword access (ex_if_type_i == 2'b01): valid if LSBs are 00 or 10.
  // For word access (ex_if_type_i == 2'b10): valid only if LSBs are 00.
  wire valid_align;
  assign valid_align = (ex_if_type_i == 2'b00) ||
                       ((ex_if_type_i == 2'b01) && ((eff_addr[1:0] == 2'b00) || (eff_addr[1:0] == 2'b10))) ||
                       ((ex_if_type_i == 2'b10) && (eff_addr[1:0] == 2'b00));

  // Main state machine
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state              <= IDLE;
      ex_if_ready_o      <= 1'b1;
      dmem_req_o         <= 1'b0;
      dmem_req_addr_o    <= 32'b0;
      dmem_req_we_o      <= 1'b0;
      dmem_req_be_o      <= 4'b0;
      dmem_req_wdata_o   <= 32'b0;
      wb_if_rvalid_o     <= 1'b0;
      wb_if_rdata_o      <= 32'b0;
    end
    else begin
      case (state)
        IDLE: begin
          // In IDLE, LSU is ready for a new request.
          ex_if_ready_o      <= 1'b1;
          dmem_req_o         <= 1'b0;
          dmem_req_addr_o    <= 32'b0;
          dmem_req_we_o      <= 1'b0;
          dmem_req_be_o      <= 4'b0;
          dmem_req_wdata_o   <= 32'b0;
          wb_if_rvalid_o     <= 1'b0;
          wb_if_rdata_o      <= 32'b0;

          // Accept new request only if EX stage is requesting and alignment is valid.
          if (ex_if_req_i && ex_if_ready_o && valid_align) begin
            // Latch the effective address and transaction details.
            eff_addr_reg    <= eff_addr;
            type_reg        <= ex_if_type_i;
            is_store_reg    <= ex_if_we_i;
            req_wdata_reg   <= ex_if_wdata_i;

            // Compute the byte enable mask based on the type and effective address.
            case (type_reg)
              2'b00: begin
                // Byte access: enable only the byte at offset eff_addr[1:0]
                be_mask_reg <= 4'b0001 << eff_addr_reg[1:0];
              end
              2'b01: begin
                // Halfword access: enable two consecutive bytes.
                if (eff_addr_reg[1:0] == 2'b00)
                  be_mask_reg <= 4'b0011;  // Lower two bytes
                else if (eff_addr_reg[1:0] == 2'b10)
                  be_mask_reg <= 4'b1100;  // Upper two bytes
                else
                  be_mask_reg <= 4'b0000;  // Misaligned (should not occur due to valid_align)
              end
              2'b10: begin
                // Word access: enable all 4 bytes.
                if (eff_addr_reg[1:0] == 2'b00)
                  be_mask_reg <= 4'b1111;
                else
                  be_mask_reg <= 4'b0000;  // Misaligned access
              end
              default: be_mask_reg <= 4'b0000;
            endcase

            state <= SENT;
          end
        end

        SENT: begin
          // Drive the data-cache interface signals.
          ex_if_ready_o      <= 1'b0;
          dmem_req_o         <= 1'b1;
          dmem_req_addr_o    <= eff_addr_reg;
          dmem_req_we_o      <= is_store_reg;
          dmem_req_be_o      <= be_mask_reg;
          dmem_req_wdata_o   <= req_wdata_reg;
          wb_if_rvalid_o     <= 1'b0;
          wb_if_rdata_o      <= 32'b0;

          // For store transactions, wait for dmem_gnt_i.
          if (is_store_reg) begin
            if (dmem_gnt_i)
              state <= IDLE;
          end
          // For load transactions, wait for dmem_rvalid_i.
          else begin
            if (dmem_rvalid_i) begin
              rdata_reg <= dmem_rsp_rdata_i;
              state <= WAIT_LOAD;
            end
          end
        end

        WAIT_LOAD: begin
          // Provide the read data to the writeback stage.
          ex_if_ready_o      <= 1'b0;
          dmem_req_o         <= 1'b0;
          dmem_req_addr_o    <= 32'b0;
          dmem_req_we_o      <= 1'b0;
          dmem_req_be_o      <= 4'b0;
          dmem_req_wdata_o   <= 32'b0;
          wb_if_rvalid_o     <= 1'b1;
          wb_if_rdata_o      <= rdata_reg;
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule