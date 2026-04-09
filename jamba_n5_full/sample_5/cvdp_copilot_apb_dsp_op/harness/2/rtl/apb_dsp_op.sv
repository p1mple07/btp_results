`timescale 1ns / 1ps

module apb_dsp_op #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
) (
    input  logic                  clk_dsp,    // Faster clock to DSP operation
    input  logic                  en_clk_dsp, // Enable DSP operation with faster clock
    input  logic                  PCLK,       // APB clock
    input  logic                  PRESETn,    // Active low asynchronous APB Reset
    input  logic [ADDR_WIDTH-1:0] PADDR,      // APB address
    input  logic                  PWRITE,     // Write/Read enable
    input  logic [DATA_WIDTH-1:0] PWDATA,     // Write data
    input  logic                  PSEL,       // DSP selector
    input  logic                  PENABLE,    // APB enable
    output logic [DATA_WIDTH-1:0] PRDATA,     // Read data
    output logic                  PREADY      // Ready signal
);

    // Clock domain synchronizer for APB‑to‑DSP data transfers
    logic sync_ack;
    always_ff @(posedge PCLK) begin
        if (en_clk_dsp) begin
            if (PWRITE) begin
                // Read data from APB and synchronise to DSP domain
                sync_ack <= (sram_data_in == reg_addr_sram);
            end else begin
                sync_ack <= 1'b0;
            end
        end else begin
            sync_ack <= 1'b1;
        end
    end

    // Detect invalid APB access (address out of range)
    assign PSLVERR = (PADDR >= 32'hFFF0) or (PADDR < 0);

    // APB handshake logic
    if (PWRITE) begin
        if (PSEL && PENABLE) begin
            // Check for a valid register access
            if (PADDR == REG_OPERAND_A) begin
                if (reg_control == DSP_READ_OP_A) reg_operand_a <= reg_addr_sram;
                if (reg_control == DSP_READ_OP_B) reg_operand_b <= reg_addr_sram;
                if (reg_control == DSP_READ_OP_C) reg_operand_c <= reg_addr_sram;
                if (reg_control == DSP_WRITE_OP_O) reg_operand_o <= reg_addr_sram;
            end
        end
    end

    // DSP operation
    always_ff @(posedge dsp_clk_sel) begin
        case (reg_control)
            DSP_READ_OP_A  : wire_op_a <= sram_data_out;
            DSP_READ_OP_B  : wire_op_b <= sram_data_out;
            DSP_READ_OP_C  : wire_op_c <= sram_data_out;
        endcase
    end

    assign wire_op_o = (wire_op_a * wire_op_b) + wire_op_c;

endmodule
