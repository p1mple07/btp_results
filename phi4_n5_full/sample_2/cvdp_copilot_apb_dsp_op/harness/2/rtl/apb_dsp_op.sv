/* 
 * apb_dsp_op.sv
 *
 * This module implements an APB interface for DSP operations on an SRAM.
 * It fixes the APB handshake by asserting PSLVERR when an invalid address is accessed,
 * and removes the direct clock‐mux between PCLK and clk_dsp by partitioning the design
 * into two clock domains (APB: PCLK; DSP: clk_dsp) with proper dual‐flop synchronizers.
 *
 * The register bank is defined as follows:
 *   REG_OPERAND_A  at 0x00  (read/write)
 *   REG_OPERAND_B  at 0x01  (read/write)
 *   REG_OPERAND_C  at 0x02  (read/write)
 *   REG_OPERAND_O  at 0x03  (read/write)
 *   REG_CONTROL    at 0x04  (read/write)
 *   REG_WDATA_SRAM at 0x05  (read/write)
 *   REG_ADDR_SRAM  at 0x06  (read/write)
 *
 * Control modes (value in REG_CONTROL):
 *   32'd1: SRAM_WRITE      – Write to SRAM using REG_WDATA_SRAM.
 *   32'd2: SRAM_READ       – Read from SRAM (result returned on PRDATA).
 *   32'd3: DSP_READ_OP_A   – Read SRAM at address in REG_OPERAND_A into DSP operand A.
 *   32'd4: DSP_READ_OP_B   – Read SRAM at address in REG_OPERAND_B into DSP operand B.
 *   32'd5: DSP_READ_OP_C   – Read SRAM at address in REG_OPERAND_C into DSP operand C.
 *   32'd6: DSP_WRITE_OP_O  – Compute DSP result and write it to SRAM at address in REG_OPERAND_O.
 *   Other values: Default internal register access.
 */

module apb_dsp_op #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
) (
    input  logic                  clk_dsp,    // DSP clock (500 MHz)
    input  logic                  en_clk_dsp, // Enable DSP clock (not used directly)
    input  logic                  PCLK,       // APB clock (50 MHz)
    input  logic                  PRESETn,    // Active low asynchronous APB reset
    input  logic [ADDR_WIDTH