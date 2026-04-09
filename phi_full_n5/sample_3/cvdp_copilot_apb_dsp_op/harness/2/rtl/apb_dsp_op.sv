// Updated APB DSP Operation Module
module apb_dsp_op #(
    parameter ADDR_WIDTH = 'd8,
    parameter DATA_WIDTH = 'd32
) (
    input  logic                  clk_dsp,    // Faster clock to DSP operation
    input  logic                  en_clk_dsp, // Enable faster DSP clock
    input  logic                  PCLK,       // APB clock
    input  logic                  PRESETn,    // Active low asynchronous APB Reset
    input  logic [ADDR_WIDTH-1:0] PADDR,      // APB address
    input  logic                  PWRITE,     // Write/Read enable
    input  logic [DATA_WIDTH-1:0] PWDATA,     // Write data
    input  logic                  PSEL,       // DSP selector
    input  logic                  PENABLE,    // APB enable
    output logic [DATA_WIDTH-1:0] PRDATA,     // Read data
    output logic                  PREADY      // Ready signal
    output logic PSLVERR             // Error signal
);

    // Clock domain crossing synchronizer
    logic sync_clk_dsp, sync_PCLK;
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            sync_clk_dsp <= PCLK;
            sync_PCLK <= en_clk_dsp;
        end
    end

    // Internal registers address map
    localparam ADDRESS_A         = 32'h0;  // 0x00
    localparam ADDRESS_B         = 32'h4;  // 0x04
    localparam ADDRESS_C         = 32'h8;  // 0x08
    localparam ADDRESS_O         = 32'hC;  // 0x0C
    localparam ADDRESS_CONTROL   = 32'h10; // 0x10
    localparam ADDRESS_WDATA     = 32'h14; // 0x14
    localparam ADDRESS_SRAM_ADDR = 32'h18; // 0x18

    // Control modes
    localparam SRAM_WRITE     = 32'd1;
    localparam SRAM_READ      = 32'd2;
    localparam DSP_READ_OP_A  = 32'd3;
    localparam DSP_READ_OP_B  = 32'd4;
    localparam DSP_READ_OP_C  = 32'd5;
    localparam DSP_WRITE_OP_O = 32'd6;

    // Internal signals
    logic [DATA_WIDTH-1:0] reg_operand_a;
    logic [DATA_WIDTH-1:0] reg_operand_b;
    logic [DATA_WIDTH-1:0] reg_operand_c;
    logic [DATA_WIDTH-1:0] reg_operand_o;
    logic [DATA_WIDTH-1:0] reg_control;
    logic [DATA_WIDTH-1:0] reg_wdata_sram;
    logic [DATA_WIDTH-1:0] reg_addr_sram;

    logic signed [DATA_WIDTH-1:0] wire_op_a;
    logic signed [DATA_WIDTH-1:0] wire_op_b;
    logic signed [DATA_WIDTH-1:0] wire_op_c;
    logic signed [DATA_WIDTH-1:0] wire_op_o;
    logic        [DATA_WIDTH-1:0] sram_data_in;
    logic                         sram_we;
    logic        [DATA_WIDTH-1:0] sram_addr;
    logic        [DATA_WIDTH-1:0] sram_data_out;

    // APB interface logic with PSLVERR
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            reg_operand_a  <= 'd0;
            reg_operand_b  <= 'd0;
            reg_operand_c  <= 'd0;
            reg_operand_o  <= 'd0;
            reg_control    <= 'd0;
            reg_wdata_sram <= 'd0;
            reg_addr_sram  <= 'd0;
            PREADY <= 1'b0;
            PSLVERR <= 1'b0; // Initialize PSLVERR to 0
        end else if (PENABLE & PSEL) begin
            PREADY <= 1'b1;
            if (reg_control == SRAM_WRITE) begin
                if (PADDR < ADDRESS_A || PADDR > ADDRESS_SRAM_ADDR) begin
                    PSLVERR <= 1'b1; // Assert PSLVERR for invalid address
                end else begin
                    reg_wdata_sram <= PWDATA;
                end
            end else if (reg_control == DSP_WRITE_OP_O) begin
                if (PADDR < ADDRESS_O || PADDR > ADDRESS_WDATA) begin
                    PSLVERR <= 1'b1; // Assert PSLVERR for invalid address
                end else begin
                    reg_operand_o <= PWDATA;
                end
            end
        end
    end

    // Synchronized SRAM interface
    always_ff @(posedge sync_clk_dsp) begin
        if (sram_we) begin
            mem[sram_addr] <= sram_data_in;
        end else begin
            sram_data_out <= mem[sram_addr];
        end
    end

    // DSP operation with synchronized clock
    always_comb begin
        sram_data_in = (reg_control == SRAM_WRITE) ? reg_wdata_sram : wire_op_o;

        // Synchronize PWRITE and PSEL from clk_dsp domain
        always_comb begin
            if (PWRITE & PSEL) begin
                if (sync_PCLK) begin
                    case (PADDR)
                        ADDRESS_A         : reg_operand_a  <= sram_data_out;
                        ADDRESS_B         : reg_operand_b  <= sram_data_out;
                        ADDRESS_C         : reg_operand_c  <= sram_data_out;
                        ADDRESS_O         : reg_operand_o  <= sram_data_out;
                        ADDRESS_CONTROL   : reg_control    <= sram_data_out;
                        ADDRESS_WDATA     : reg_wdata_sram <= sram_data_out;
                        ADDRESS_SRAM_ADDR : reg_addr_sram  <= sram_data_out;
                    endcase
                end
            end
        end

        // Synchronize PREADY from clk_dsp domain
        always_comb begin
            PREADY <= sync_clk_dsp; // Synchronize PREADY from clk_dsp
        end

        // DSP operation with synchronized clock
        always_ff @(posedge clk_dsp) begin
            case (reg_control)
                DSP_READ_OP_A  : wire_op_a <= sram_data_out;
                DSP_READ_OP_B  : wire_op_b <= sram_data_out;
                DSP_READ_OP_C  : wire_op_c <= sram_data_out;
            endcase
        end

        assign wire_op_o = (wire_op_a * wire_op_b) + wire_op_c;
    endmodule
