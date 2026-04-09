// APB DSP Operation Module
module apb_dsp_op #(
    parameter ADDR_WIDTH = 'd8,
    parameter DATA_WIDTH = 'd32
) (
    input  logic                  clk_dsp,    // Faster clock to DSP operation
    input  logic                  en_clk_dsp, // Enable DSP operation with faster clock
    input  logic                  PCLK,       // APB clock
    input  logic                  PRESETn,    // Active low asynchronous APB Reset
    input  logic [ADDR_WIDTH-1:0] PADDR,      // APB address
    input  logic [DATA_WIDTH-1:0] PWDATA,     // Write data
    input  logic [32]             PSEL,       // DSP selector
    input  logic [1]              PENABLE,    // APB enable
    output logic [DATA_WIDTH-1:0] PRDATA,     // Read data
    output logic                  PREADY      // Ready signal
);

    // APB interface logic with clock domain synchronization
    logic [DATA_WIDTH-1:0] sram_data_out;
    logic [DATA_WIDTH-1:0] sram_data_in;
    logic [DATA_WIDTH-1:0] sram_we;
    logic [ADDR_WIDTH-1:0] sram_addr;
    logic [1]              clock_synth;

    // Clock selection with dual-flop synchronizer
    logic clock_sel = en_clk_dsp ? (clk_dsp & ~PCLK) : PCLK;
    always_ff @(posedge clock_sel or negedge PRESETn) begin
        if (!PRESETn) begin
            if (clock_sel) begin
                clock_synth = 1;
                sram_data_in = 1;
                sram_we = 0;
            end
        end else if (PENABLE & PSEL) begin
            if (PWRITE) begin
                case (PADDR)
                    ADDRESS_A         : sram_addr = reg_operand_a;
                    ADDRESS_B         : sram_addr = reg_operand_b;
                    ADDRESS_C         : sram_addr = reg_operand_c;
                    ADDRESS_O         : sram_addr = reg_operand_o;
                    ADDRESS_CONTROL   : sram_addr = reg_control;
                    ADDRESS_WDATA     : sram_addr = reg_wdata_sram;
                    ADDRESS_SRAM_ADDR : sram_addr = reg_addr_sram;
                endcase
            end else begin
                if (reg_control == SRAM_READ) begin
                    PRDATA <= sram_data_out;
                end else begin
                    case (PADDR)
                        ADDRESS_A         : PRDATA <= reg_operand_a;
                        ADDRESS_B         : PRDATA <= reg_operand_b;
                        ADDRESS_C         : PRDATA <= reg_operand_c;
                        ADDRESS_O         : PRDATA <= reg_operand_o;
                        ADDRESS_CONTROL   : PRDATA <= reg_control;
                        ADDRESS_WDATA     : PRDATA <= reg_wdata_sram;
                        ADDRESS_SRAM_ADDR : PRDATA <= reg_addr_sram;
                    endcase
                end
            end
        end
    end

    // SRAM logic with clock domain synchronization
    always_comb begin
        sram_data_in = (reg_control == SRAM_WRITE) ? reg_wdata_sram : wire_op_o;
        sram_we = (reg_control == SRAM_WRITE) ? 1 : 0;
    end

    // APB interface signals
    logic [DATA_WIDTH-1:0] reg_operand_a;
    logic [DATA_WIDTH-1:0] reg_operand_b;
    logic [DATA_WIDTH-1:0] reg_operand_c;
    logic [DATA_WIDTH-1:0] reg_operand_o;
    logic [DATA_WIDTH-1:0] reg_control;
    logic [DATA_WIDTH-1:0] reg_wdata_sram;
    logic [DATA_WIDTH-1:0] reg_addr_sram;

    // APB transaction control
    logic clock_synth;
    logic clock_sel;
    logic [1] clock_synth;

    // APB ready signal handling
    always_ff @(posedge clock_sel or negedge PRESETn) begin
        if (PSEL && PENABLE) begin
            if (PWRITE) begin
                if (reg_control == SRAM_READ) begin
                    PRDATA <= sram_data_out;
                end else begin
                    case (PADDR)
                        ADDRESS_A         : PRDATA <= reg_operand_a;
                        ADDRESS_B         : PRDATA <= reg_operand_b;
                        ADDRESS_C         : PRDATA <= reg_operand_c;
                        ADDRESS_O         : PRDATA <= reg_operand_o;
                        ADDRESS_CONTROL   : PRDATA <= reg_control;
                        ADDRESS_WDATA     : PRDATA <= reg_wdata_sram;
                        ADDRESS_SRAM_ADDR : PRDATA <= reg_addr_sram;
                    endcase
                end
            end else begin
                if (reg_control == SRAM_READ) begin
                    PRDATA <= sram_data_out;
                end else begin
                    case (PADDR)
                        ADDRESS_A         : PRDATA <= reg_operand_a;
                        ADDRESS_B         : PRDATA <= reg_operand_b;
                        ADDRESS_C         : PRDATA <= reg_operand_c;
                        ADDRESS_O         : PRDATA <= reg_operand_o;
                        ADDRESS_CONTROL   : PRDATA <= reg_control;
                        ADDRESS_WDATA     : PRDATA <= reg_wdata_sram;
                        ADDRESS_SRAM_ADDR : PRDATA <= reg_addr_sram;
                    endcase
                end
            end
        end else if (PSEL && PENABLE && PWRITE) begin
            PREADY <= 1;
        end else begin
            PREADY <= 0;
        end
    end