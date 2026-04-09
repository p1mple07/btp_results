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
    input  logic                 ex_if_extend_mode_i,
    output logic                 ex_if_ready_o,

    // Writeback stage interface
    output logic     [31:0]      wb_if_rdata_o,         // Requested data
    output logic                 wb_if_rvalid_o,

    // Data memory (DMEM) interface
    output logic                 dmem_req_o,
    input  logic                 dmem_gnt_i,
    output logic     [31:0]      dmem_req_addr_o,
    output logic                 dmem_req_we_o,
    output logic     [31:30]     dmem_req_be_o,
    output logic     [31:0]      dmem_req_wdata_o,
    input  logic     [31:0]      dmem_rsp_rdata_i,
    input  logic                 dmem_rvalid_i
);

  // FSM state
  logic state                 state;

  // Internal signals
  logic ex_req_fire;
  logic dmem_req_we_q;
  logic [31:0] data_addr_int;
  logic misaligned_addr;
  logic [3:0] dmem_be, dmem_req_be_q;

  logic busy_q;  
  logic dmem_req_q ;

  logic [31:0] dmem_req_wdata_q;
  logic [31:0] dmem_req_addr_q;
  logic [31:0] dmem_req_we_q;
  logic [31:0] dmem_req_be_q;

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
      2'b01: begin  
          case (data_addr_int[1:0])
            2'b00: dmem_be = 4'b0011;
            2'b10: dmem_be = 4'b1100;
            default: begin
                dmem_be = 4'b0000;
                misaligned_addr = 1'b1;
            end
      endcase
      2'b10: begin  
          case (data_addr_int[1:0])
            2'b00: dmem_be = 4'b1111;
            default: begin
                dmem_be = 4'b0000;
                misaligned_addr = 1'b1;
            end
          endcase
          default: begin
              dmem_be = 4'b0000;
              misaligned_addr = 1'b1;
          end 
      endcase
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
      rdata_offset_q <= '0 ; 
    end else if (ex_req_fire) begin
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= ex_if_we_i;
      dmem_req_be_q <= dmem_be ;
      dmem_req_wdata_q <= ex_if_wdata_i ; 

      rdata_offset_q <= data_addr_int[1:0] ; 
      data_sign_ext_q <= ex_if_extend_mode_i ;
      data_type_q <= ex_if_type_i ;
    end else if (dmem_req_q && dmem_gnt_i) begin
      dmem_req_q <= 1'b0;  
      dmem_req_addr_q <= '0 ;
      dmem_req_we_q <= '0 ;
      dmem_req_be_q <= '0 ;
      dmem_req_wdata_q <= '0 ;
    end
  end

  always_comb begin
    case (rdata_offset_q)
      2'b00: rdata_w_ext = dmem_rsp_rdata_i[31:0];
      default: rdata_w_ext = '0 ;
    endcase
  end

  always_comb begin
    case (rdata_offset_q)
      2'b00: begin
        if (data_sign_ext_q) rdata_h_ext = {{16{dmem_rsp_rdata_i[15]}}, dmem_rsp_rdata_i[15:0]};
        else rdata_h_ext =  {16'h0000, dmem_rsp_rdata_i[15:0]};
      end

      2'b10: begin
        if (data_sign_ext_q) rdata_h_ext = {{16{dmem_rsp_rdata_i[31]}}, dmem_rsp_rdata_i[31:16]};
        else rdata_h_ext =  {16'h0000, dmem_rsp_rdata_i[31:16]};
      end

      default: begin
        rdata_h_ext = '0 ;  
      end
    endcase  
  end

  always_comb begin
    case (rdata_offset_q)
      2'b00: begin
        if (data_sign_ext_q) rdata_b_ext  = {{24{dmem_rsp_rdata_i[7]}}, dmem_rsp_rdata_i[7:0]}; 
        else rdata_b_ext = {24'h00_0000, dmem_rsp_rdata_i[7:0]};
      end

      2'b01: begin
        if (data_sign_ext_q) rdata_b_ext  = {{24{dmem_rsp_rdata_i[15]}}, dmem_rsp_rdata_i[15:8]}; 
        else rdata_b_ext = {24'h00_0000, dmem_rsp_rdata_i[15:8]};
      end

      2'b10: begin
        if (data_sign_ext_q) rdata_b_ext  = {{24{dmem_rsp_rdata_i[23]}}, dmem_rsp_rdata_i[23:16]}; 
        else rdata_b_ext = {24'h00_0000, dmem_rsp_rdata_i[23:16]};
      end

      2'b11: begin
        if (data_sign_ext_q) rdata_b_ext  = {{24{dmem_rsp_rdata_i[31]}}, dmem_rsp_rdata_i[31:24]}; 
        else rdata_b_ext = {24'h00_0000, dmem_rsp_rdata_i[31:24]};
      end
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
      dmem_req_q <= 1'b0;
      dmem_req_addr_q <= '0;
    end else if (ex_req_fire) begin
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= ex_if_we_i;
      dmem_req_be_q <= dmem_be ;
      dmem_req_wdata_q <= ex_if_wdata_i ; 
    end else if (dmem_req_q && dmem_gnt_i) begin
      dmem_req_q <= 1'b0;  
    end
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      busy_q <= 1'b0;
    end else if (ex_req_fire) begin
      busy_q <= 1'b1;
    end else if (dmem_req_q && dmem_gnt_i) begin
      busy_q <= 1'b0;  
    end else if (!dmem_req_we_q && dmem_rvalid_i) begin
      busy_q <= 1'b0;  
    end
  end

  always_comb begin
    case (state)  
      'IDLE: 
        state = 'IDLE'; 
      'ALIGNED_RD: 
        state = 'IDLE'; 
      'MISALIGNED_RD: 
        state = 'MISALIGNED_RD_1'; 
      'MISALIGNED_RD_1': 
        state = 'IDLE'; 
      'ALIGNED_WR: 
        state = 'IDLE'; 
      'MISALIGNED_WR: 
        state = 'MISALIGNED_WR_1'; 
      'MISALIGNED_WR_1': 
        state = 'IDLE'; 
      'MISALIGNED_RD_GNT: 
        state = 'MISALIGNED_RD_1'; 
      'MISALIGNED_RD_1': 
        state = 'MISALIGNED_RD_GNT_1'; 
      'MISALIGNED_RD_GNT_1': 
        state = 'IDLE'; 
      'MISALIGNED_RD_GNT_1': 
        state = 'IDLE'; 
    endcase
  end

  // Add FSM state and transitions here
  logic state;
  // ... (rest of the code remains the same)