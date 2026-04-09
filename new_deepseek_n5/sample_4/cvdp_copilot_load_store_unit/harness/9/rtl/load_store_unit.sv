// Module structure remains the same, only internal signals and logic are modified

module load_store_unit (
    input  logic                 clk,
    input  logic                 rst_n,

    input  logic                 ex_if_req_i,           // LSU request
    input  logic                 ex_if_we_i,            // Write enable: 0 (load), 1 (store)
    input  logic     [ 1:0]      ex_if_type_i,          // Data type: 0x2 (word), 0x1 (halfword), 0x0 (byte)
    input  logic     [31:0]      ex_if_wdata_i,         // Data to write to memory
    input  logic     [31:0]      ex_if_addr_base_i,     // Base address
    input  logic     [31:0]      ex_if_addr_offset_i,   // Offset address
    input  logic     [31:0]      ex_if_extend_mode_i,
    output logic                 ex_if_ready_o,          // Ready signal

    // FSM states
    input logic state,
    input logic state_next,
    input logic state_valid,

    // Bus transaction control signals
    output logic first_transaction,
    output logic second_transaction,

    // Data memory interface
    output logic dmem_req_o,
    input  logic dmem_gnt_i,
    output logic dmem_req_addr_o,
    output logic dmem_req_we_o,
    output logic dmem_req_be_o,
    output logic dmem_req_wdata_o,
    input  logic dmem_rsp_rdata_i,
    input  logic dmem_rvalid_i,

    // Internal signals
    logic ex_req_fire;
    logic dmem_be;
    logic [31:0] data_addr_int;
    logic misaligned_addr;
    logic [3:0] dmem_be, dmem_req_be_q;

    logic [31:0] dmem_req_wdata_q;
    logic [31:0] dmem_req_addr_q;
    logic [31:0] dmem_req_we_q;
    logic [31:0] dmem_req_be_q;

    assign data_addr_int = ex_if_addr_base_i + ex_if_addr_offset_i;

    assign ex_req_fire = ex_if_req_i && !busy_q && !misaligned_addr;
    assign ex_if_ready_o = !busy_q;

    always_comb begin
        misaligned_addr = 1'b0;
        dmem_be = 4'b0000;
        case (ex_if_type_i)  
            2'b00: begin  
                case (data_addr_int[1:0])
                    2'b00: dmem_be = 4'b0001;
                    2'b10: dmem_be = 4'b0010;
                    default: dmem_be = 4'b0100;
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
            first_transaction <= '0;
            second_transaction <= '0;
        end else if (ex_req_fire) begin
            dmem_req_q <= 1'b1;
            dmem_req_addr_q <= data_addr_int;
            dmem_req_we_q <= ex_if_we_i;
            dmem_req_be_q <= dmem_be;
            dmem_req_wdata_q <= ex_if_wdata_i;

            first_transaction <= '0;
            second_transaction <= '0;

            if (data_addr_int[1:0] == 2'b11) begin
                first_transaction <= 1;
                second_transaction <= 1;
            end
        end else if (dmem_req_q && dmem_gnt_i) begin
            dmem_req_q <= 1'b0;
            dmem_req_addr_q <= '0;
            dmem_req_we_q <= '0 ;
            dmem_req_be_q <= '0 ;
            dmem_req_wdata_q <= '0 ;
            first_transaction <= '0;
            second_transaction <= '0;
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

    always_comb begin : dmem_req
        dmem_req_o        = dmem_req_q;
        dmem_req_addr_o   = dmem_req_addr_q;
        dmem_req_we_o     = dmem_req_we_q;
        dmem_req_be_o     = dmem_req_be_q;
        dmem_req_wdata_o  = dmem_req_wdata_q;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            first_transaction <= '0;
            second_transaction <= '0;
        end else if (ex_if_req_i && ex_if_we_i && ex_if_type_i) begin
            if (data_addr_int[1:0] == 2'b11) begin
                first_transaction <= 1;
                second_transaction <= 1;
            else if (data_addr_int[1:0] != 2'b00) begin
                first_transaction <= 1;
                second_transaction <= 0;
            else begin
                first_transaction <= 0;
                second_transaction <= 0;
            end
        end else if (dmem_req_q && dmem_gnt_i) begin
            first_transaction <= 0;
            second_transaction <= 0;
        end
    end

    assign first_transaction <= first_transaction;
    assign second_transaction <= second_transaction;

    always_comb begin
        case (data_type_q)
            2'b00: begin
                if (data_sign_ext_q) rdata_h_ext = {{16{dmem_rsp_rdata_i[15]}}, dmem_rsp_rdata_i[15:0]};
                else rdata_h_ext = {16'h0000, dmem_rsp_rdata_i[15:0]};
            end
            2'b01: begin
                if (data_sign_ext_q) rdata_h_ext = {{16{dmem_rsp_rdata_i[31]}}, dmem_rsp_rdata_i[31:16]};
                else rdata_h_ext = {16'h0000, dmem_rsp_rdata_i[31:16]};
            end
            2'b10: begin
                if (data_sign_ext_q) rdata_h_ext = {{24{dmem_rsp_rdata_i[7]}}, dmem_rsp_rdata_i[7:0]};
                else rdata_h_ext = {24'h00_0000, dmem_rsp_rdata_i[7:0]};
            end
            2'b11: begin
                if (data_sign_ext_q) rdata_h_ext = {{24{dmem_rsp_rdata_i[31]}}, dmem_rsp_rdata_i[31:24]};
                else rdata_h_ext = {24'h00_0000, dmem_rsp_rdata_i[31:24]};
            end
        endcase
    end

    always_comb begin
        case (data_type_q)
            2'b00: begin
                if (data_sign_ext_q) rdata_b_ext  = {{16{dmem_rsp_rdata_i[15]}}, dmem_rsp_rdata_i[15:0]};
                else rdata_b_ext = {16'h0000, dmem_rsp_rdata_i[15:0]};
            end
            2'b01: begin
                if (data_sign_ext_q) rdata_b_ext  = {{16{dmem_rsp_rdata_i[31]}}, dmem_rsp_rdata_i[31:16]};
                else rdata_b_ext = {16'h0000, dmem_rsp_rdata_i[31:16]};
            end
            2'b10: begin
                if (data_sign_ext_q) rdata_b_ext  = {{24{dmem_rsp_rdata_i[7]}}, dmem_rsp_rdata_i[7:0]};
                else rdata_b_ext = {24'h00_0000, dmem_rsp_rdata_i[7:0]};
            end
            2'b11: begin
                if (data_sign_ext_q) rdata_b_ext  = {{24{dmem_rsp_rdata_i[31]}}, dmem_rsp_rdata_i[31:24]};
                else rdata_b_ext = {24'h00_0000, dmem_rsp_rdata_i[31:24]};
            end
        endcase
    end

    always_comb begin
        case (data_type_q)
            2'b00: begin
                if (data_sign_ext_q) rdata_w_ext = {{16{dmem_rsp_rdata_i[15]}}, dmem_rsp_rdata_i[15:0]};
                else rdata_w_ext = {16'h0000, dmem_rsp_rdata_i[15:0]};
            end
            2'b01: begin
                if (data_sign_ext_q) rdata_w_ext = {{16{dmem_rsp_rdata_i[31]}}, dmem_rsp_rdata_i[31:16]};
                else rdata_w_ext = {16'h0000, dmem_rsp_rdata_i[31:16]};
            end
            2'b10: begin
                if (data_sign_ext_q) rdata_w_ext = {{24{dmem_rsp_rdata_i[7]}}, dmem_rsp_rdata_i[7:0]};
                else rdata_w_ext = {24'h00_0000, dmem_rsp_rdata_i[7:0]};
            end
            2'b11: begin
                if (data_sign_ext_q) rdata_w_ext = {{24{dmem_rsp_rdata_i[31]}}, dmem_rsp_rdata_i[31:24]};
                else rdata_w_ext = {24'h00_0000, dmem_rsp_rdata_i[31:24]};
            end
        endcase
    end

    always_comb begin
        case (data_type_q)
            2'b00: data_rdata_ext = rdata_b_ext ;
            2'b01: data_rdata_ext = rdata_h_ext;
            2'b10: data_rdata_ext = rdata_w_ext;
            default: data_rdata_ext = 32'b0;
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
            first_transaction <= '0;
            second_transaction <= '0;
        end else if (ex_if_req_i && ex_if_we_i && ex_if_type_i) begin
            if (data_addr_int[1:0] == 2'b11) begin
                first_transaction <= 1;
                second_transaction <= 1;
            else if (data_addr_int[1:0] != 2'b00) begin
                first_transaction <= 1;
                second_transaction <= 0;
            else begin
                first_transaction <= 0;
                second_transaction <= 0;
            end
        end else if (dmem_req_q && dmem_gnt_i) begin
            first_transaction <= 0;
            second_transaction <= 0;
        end
    end