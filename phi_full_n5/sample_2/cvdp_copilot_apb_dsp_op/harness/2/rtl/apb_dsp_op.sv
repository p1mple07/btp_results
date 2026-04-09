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
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            sync_clk_dsp = en_clk_dsp;
            sync_PCLK = PCLK;
        end
    end

    // APB interface logic with synchronization
    always @(posedge sync_PCLK) begin
        if (!PRESETn) begin
            reg_operand_a  <= 32'h0;
            reg_operand_b  <= 32'h0;
            reg_operand_c  <= 32'h0;
            reg_operand_o  <= 32'h0;
            reg_control    <= 32'h0;
            reg_wdata_sram <= 32'h0;
            reg_addr_sram  <= 32'h0;
            PREADY <= 1'b0;
        end else if (PENABLE & PSEL) begin
            PREADY <= 1'b1;
            if (PWRITE) begin
                case (PADDR)
                    ADDRESS_A         : reg_operand_a  <= PWDATA;
                    ADDRESS_B         : reg_operand_b  <= PWDATA;
                    ADDRESS_C         : reg_operand_c  <= PWDATA;
                    ADDRESS_O         : reg_operand_o  <= PWDATA;
                    ADDRESS_CONTROL   : reg_control    <= PWDATA;
                    ADDRESS_WDATA     : reg_wdata_sram <= PWDATA;
                    ADDRESS_SRAM_ADDR : reg_addr_sram  <= PWDATA;
                endcase
            end else begin
                if (reg_control == SRAM_READ && within_valid_range(PADDR)) begin
                    PRDATA <= sram_data_out;
                end else begin
                    PSLVERR <= 1'b1; // Assert error signal for invalid access
                end
            end
        end
    end

    // SRAM logic with synchronization
    logic [DATA_WIDTH-1:0] mem [63:0];
    logic sram_we;
    logic [DATA_WIDTH-1:0] sram_addr;
    logic [DATA_WIDTH-1:0] sram_data_in;
    logic sram_data_out;

    always @(posedge sync_clk_dsp) begin
        if (sram_we) begin
            mem[sram_addr] <= sram_data_in;
        end else begin
            sram_data_out <= mem[sram_addr];
        end
    end

    // Synchronize PADDR and PWDATA for SRAM access
    assign sram_addr = reg_operand_a;
    assign sram_data_in = (reg_control == SRAM_READ) ? reg_wdata_sram : reg_operand_o;

    // Dual-flop synchronizer for address and data
    always @(posedge sync_clk_dsp) begin
        if (PSEL) begin
            sync_addr <= PADDR;
            sync_data <= PWDATA;
        end
    end

    // Synchronize PENABLE for controlling read/write
    always @(posedge sync_clk_dsp) begin
        if (PENABLE) begin
            reg_control <= sync_data;
        end
    end

    // DSP operation
    always_comb begin
        case (reg_control)
            DSP_READ_OP_A  : wire_op_a <= sram_data_out;
            DSP_READ_OP_B  : wire_op_b <= sram_data_out;
            DSP_READ_OP_C  : wire_op_c <= sram_data_out;
            DSP_WRITE_OP_O : wire_op_o <= reg_operand_o;
            default        : wire_op_o <= 32'h0;
        endcase
    end

    assign wire_op_o = (wire_op_a * wire_op_b) + wire_op_c;

    // Error signal handling
    always @(posedge sync_clk_dsp) begin
        if (PSEL & PENABLE & within_valid_range(sync_addr)) begin
            PSLVERR <= 1'b0; // Clear error signal for valid operation
        end
        else begin
            PSLVERR <= 1'b1; // Assert error signal for invalid operation
        end
    end

endmodule

function [32-1:0] within_valid_range(input logic [ADDR_WIDTH-1:0] addr);
    if (addr >= ADDRESS_A && addr <= ADDRESS_O) begin
        within_valid_range = 1'b1;
    end else
        within_valid_range = 1'b0;
endfunction
