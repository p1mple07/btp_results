module load_store_unit (
    input  logic                 clk,
    input  logic                 rst_n,

    // EX stage interface
    input  logic                 ex_if_req_i,           // LSU request
    input  logic                 ex_if_we_i,            // Write enable: 0 (load), 1 (store)
    input  logic     [ 1:0]      ex_if_type_i,          // Data type: 0x2 (word), 0x1 (halfword), 0x0 (byte)
    input  logic     [31:0]      ex_if_wdata_i,         // Data to write to memory
    input  logic     [31:0]      ex_if_addr_base_i,     // Base address
    input  logic     [31:0]      ex_if_addr_offset_i,   // Offset address
    input  logic     [31:0]      ex_if_extend_mode_i,
    output logic                 ex_if_ready_o,

    // Writeback stage interface
    output logic     [31:0]      wb_if_rdata_o,         // Requested data
    output logic                 wb_if_rvalid_o,        // Requested data valid

    // Data memory (DMEM) interface
    output logic                 dmem_req_o,
    input  logic                 dmem_gnt_i,
    output logic     [31:0]      dmem_req_addr_o,
    output logic                 dmem_req_we_o,
    output logic     [31:0]      dmem_req_be_o,
    output logic     [31:0]      dmem_req_wdata_o,
    input  logic     [31:0]      dmem_rsp_rdata_i,
    input  logic                 dmem_rvalid_i
);

  // Internal signals
  logic ex_req_fire;
  logic dmem_req_we_q;
  logic [31:0] data_addr_int;
  logic misaligned_addr;
  logic [31:0] dmem_be, dmem_req_be_q;

  logic busy_q;  
  logic dmem_req_q ;

  // FSM states
  logic state;
  // State descriptions:
  // IDLE: Default state where the LSU waits for a request from the execute stage.
  // ALIGNED_WR: Handles single bus transaction for an aligned store.
  // ALIGNED_RD: Handles single bus transaction for an aligned load.
  // MISALIGNED_WR: Initiates the first bus transaction for a misaligned store.
  // MISALIGNED_RD: Initiates the first bus transaction for a misaligned load.
  // MISALIGNED_WR_1: Completes the second bus transaction for a misaligned store.
  // MISALIGNED_RD_GNT: Waits for the first data response (dmem_rvalid_i) for misaligned RD.
  // MISALIGNED_RD_1: Completes the second bus transaction for a misaligned load.
  // MISALIGNED_RD_GNT_1: Waits for the second data response (dmem_rvalid_i) for misaligned RD.

  always_comb begin
    misaligned_addr = 1'b0;
    dmem_be = 4'b0000;
    case (ex_if_type_i)  
      2'b00: begin  
          case (data_addr_int[1:0])
            2'b00: dmem_be = 4'b0001;
            2'b10: dmem_be = 4'b0010;
            default: dmem_be = 4'b0000;
            misaligned_addr = 1'b1;
          endcase
      end

      2'b01: begin  
          case (data_addr_int[1:0])
            2'b00: dmem_be = 4'b0011;
            2'b10: dmem_be = 4'b1100;
            default: begin
                dmem_be = 4'b0000;
                misaligned_addr = 1'b1;
            end
          endcase
      end

      2'b10: begin  
          case (data_addr_int[1:0])
            2'b00: dmem_be = 4'b1111;
            default: begin
                dmem_be = 4'b0000;
                misaligned_addr = 1'b1;
            end
          endcase
      end
      default: begin
          dmem_be = 4'b0000;
          misaligned_addr = 1'b1;
      end 
    endcase
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      dmem_req_q <= 1'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0 ;
      dmem_req_be_q <= '0 ;
      dmem_req_wdata_q <= '0 ;
      state <= IDLE;
    end else if (ex_req_fire) begin
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= ex_if_we_i;
      dmem_req_be_q <= dmem_be ;
      dmem_req_wdata_q <= ex_if_wdata_i ; 
      state <= ALIGNED_WR;
    end else if (dmem_req_q && dmem_gnt_i) begin
      dmem_req_q <= 1'b0;  
      dmem_req_addr_q <= '0 ;
      dmem_req_we_q <= '0 ;
      dmem_req_be_q <= '0 ;
      dmem_req_wdata_q <= '0 ;
      state <= IDLE;
    end
  end

  always_comb begin : dmem_req
    dmem_req_o        = dmem_req_q;
    dmem_req_addr_o   = dmem_req_addr_q;
    dmem_req_we_o     = dmem_req_we_q;
    dmem_req_be_o     = dmem_req_be_q;
    dmem_req_wdata_o  = dmem_req_wdata_q;
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      wb_if_rdata_q   <= 32'b0;
      wb_if_rvalid_q  <= 1'b0;
      state <= IDLE;
    end else if (ex_if_type_i == 2 && !dmem_req_we_q && !misaligned_addr) begin
      // Word write
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= 1'b1;
      dmem_req_be_q <= dmem_be;
      dmem_req_wdata_q <= ex_if_wdata_i;
      state <= MISALIGNED_WR;
    end else if (ex_if_type_i == 1 && !dmem_req_we_q && !misaligned_addr) begin
      // Halfword write
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= 1'b1;
      dmem_req_be_q <= dmem_be;
      dmem_req_wdata_q <= ex_if_wdata_i;
      state <= MISALIGNED_WR_1;
    end else if (ex_if_type_i == 0 && !dmem_req_we_q && !misaligned_addr) begin
      // Byte write
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= 1'b1;
      dmem_req_be_q <= dmem_be;
      dmem_req_wdata_q <= ex_if_wdata_i;
      state <= MISALIGNED_WR_1;
    end else if (ex_if_type_i == 2 && dmem_req_we_q && dmem_gnt_i) begin
      // Word read
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= 1'b1;
      dmem_req_be_q <= dmem_be;
      dmem_req_wdata_q <= dmem_rsp_rdata_i;
      state <= MISALIGNED_RD;
    end else if (ex_if_type_i == 1 && dmem_req_we_q && dmem_gnt_i) begin
      // Halfword read
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= 1'b1;
      dmem_req_be_q <= dmem_be;
      dmem_req_wdata_q <= dmem_rsp_rdata_i;
      state <= MISALIGNED_RD_GNT;
    end else if (ex_if_type_i == 0 && dmem_req_we_q && dmem_gnt_i) begin
      // Byte read
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= 1'b1;
      dmem_req_be_q <= dmem_be;
      dmem_req_wdata_q <= dmem_rsp_rdata_i;
      state <= MISALIGNED_RD_GNT;
    end else if (dmem_req_q && !dmem_gnt_i) begin
      // Bus idle
      state <= IDLE;
    end
  end

  always_comb begin
    case (state)  
      of (IDLE)  
        break;
      of (ALIGNED_WR)  
        break;
      of (ALIGNED_RD)  
        break;
      of (MISALIGNED_WR)  
        state <= MISALIGNED_WR_1;
      of (MISALIGNED_WR_1)  
        state <= IDLE;
      of (MISALIGNED_RD)  
        state <= MISALIGNED_RD_GNT;
      of (MISALIGNED_RD_GNT)  
        state <= MISALIGNED_RD_1;
      of (MISALIGNED_RD_1)  
        state <= IDLE;
      endcase
  end

  always_comb begin : dmem_req
    dmem_req_o        = dmem_req_q;
    dmem_req_addr_o   = dmem_req_addr_q;
    dmem_req_we_o     = dmem_req_we_q;
    dmem_req_be_o     = dmem_req_be_q;
    dmem_req_wdata_o  = dmem_req_wdata_q;
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      busy_q <= 1'b0;
    end else if (ex_if_type_i == 2 && !dmem_req_we_q && !misaligned_addr) begin
      // Word store
      busy_q <= 1'b1;
    end else if (ex_if_type_i == 1 && !dmem_req_we_q && !misaligned_addr) begin
      // Halfword store
      busy_q <= 1'b1;
    end else if (ex_if_type_i == 0 && !dmem_req_we_q && !misaligned_addr) begin
      // Byte store
      busy_q <= 1'b1;
    end else if (dmem_req_q && !dmem_gnt_i) begin
      // Bus idle
      busy_q <= 1'b0;
    end
  end

  always_comb begin
    case (data_type_q)  
      2'b00: data_rdata_ext = rdata_b_ext ;
      2'b01: data_rdata_ext = rdata_h_ext;
      2'b10: data_rdata_ext = rdata_w_ext;
      default: data_rdata_ext = 32'b0;
    endcase  
  end

  always_comb begin : dmem
    dmem_req_o        = dmem_req_q;
    dmem_req_addr_o   = dmem_req_addr_q;
    dmem_req_we_o     = dmem_req_we_q;
    dmem_req_be_o     = dmem_req_be_q;
    dmem_req_wdata_o  = dmem_req_wdata_q;
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      wb_if_rdata_q   <= 32'b0;
      wb_if_rvalid_q  <= 1'b0;
    end else if (ex_if_type_i == 2 && !dmem_req_we_q && !misaligned_addr) begin
      // Word write
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= 1'b1;
      dmem_req_be_q <= dmem_be;
      dmem_req_wdata_q <= ex_if_wdata_i;
      busy_q <= 1'b1;
      state <= MISALIGNED_WR;
    end else if (ex_if_type_i == 1 && !dmem_req_we_q && !misaligned_addr) begin
      // Halfword write
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= 1'b1;
      dmem_req_be_q <= dmem_be;
      dmem_req_wdata_q <= ex_if_wdata_i;
      busy_q <= 1'b1;
      state <= MISALIGNED_WR_1;
    end else if (ex_if_type_i == 0 && !dmem_req_we_q && !misaligned_addr) begin
      // Byte write
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= 1'b1;
      dmem_req_be_q <= dmem_be;
      dmem_req_wdata_q <= ex_if_wdata_i;
      busy_q <= 1'b1;
      state <= MISALIGNED_WR_1;
    end else if (ex_if_type_i == 2 && dmem_req_we_q && dmem_gnt_i) begin
      // Word read
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= 1'b1;
      dmem_req_be_q <= dmem_be;
      dmem_req_wdata_q <= dmem_rsp_rdata_i;
      busy_q <= 1'b0;
      state <= MISALIGNED_RD;
    end else if (ex_if_type_i == 1 && dmem_req_we_q && dmem_gnt_i) begin
      // Halfword read
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= 1'b1;
      dmem_req_be_q <= dmem_be;
      dmem_req_wdata_q <= dmem_rsp_rdata_i;
      busy_q <= 1'b0;
      state <= MISALIGNED_RD_GNT;
    end else if (ex_if_type_i == 0 && dmem_req_we_q && dmem_gnt_i) begin
      // Byte read
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= 1'b1;
      dmem_req_be_q <= dmem_be;
      dmem_req_wdata_q <= dmem_rsp_rdata_i;
      busy_q <= 1'b0;
      state <= MISALIGNED_RD_GNT;
    end else if (dmem_req_q && !dmem_gnt_i) begin
      // Bus idle
      busy_q <= 1'b0;
      state <= IDLE;
    end
  end
  // End of FSM
  always_comb begin : dmem
    dmem_req_o        = dmem_req_q;
    dmem_req_addr_o   = dmem_req_addr_q;
    dmem_req_we_o     = dmem_req_we_q;
    dmem_req_be_o     = dmem_req_be_q;
    dmem_req_wdata_o  = dmem_req_wdata_q;
  end