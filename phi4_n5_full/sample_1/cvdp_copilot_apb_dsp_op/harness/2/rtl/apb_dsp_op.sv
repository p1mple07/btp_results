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
    output logic                  PREADY,     // Ready signal
    output logic                  PSLVERR     // Error signal
);

    // Internal address map (using 8-bit addresses)
    localparam ADDRESS_A         = 8'h00; // 0x00
    localparam ADDRESS_B         = 8'h04; // 0x04
    localparam ADDRESS_C         = 8'h08; // 0x08
    localparam ADDRESS_O         = 8'h0C; // 0x0C
    localparam ADDRESS_CONTROL   = 8'h10; // 0x10
    localparam ADDRESS_WDATA     = 8'h14; // 0x14
    localparam ADDRESS_SRAM_ADDR = 8'h18; // 0x18

    // Control modes
    localparam SRAM_WRITE     = 32'd1;
    localparam SRAM_READ      = 32'd2;
    localparam DSP_READ_OP_A  = 32'd3;
    localparam DSP_READ_OP_B  = 32'd4;
    localparam DSP_READ_OP_C  = 32'd5;
    localparam DSP_WRITE_OP_O = 32'd6;

    // Internal registers
    logic [DATA_WIDTH-1:0] reg_operand_a;
    logic [DATA_WIDTH-1:0] reg_operand_b;
    logic [DATA_WIDTH-1:0] reg_operand_c;
    logic [DATA_WIDTH-1:0] reg_operand_o;
    logic [DATA_WIDTH-1:0] reg_control;
    logic [DATA_WIDTH-1:0] reg_wdata_sram;
    logic [DATA_WIDTH-1:0] reg_addr_sram;

    // DSP operands and intermediate result
    logic signed [DATA_WIDTH-1:0] wire_op_a;
    logic signed [DATA_WIDTH-1:0] wire_op_b;
    logic signed [DATA_WIDTH-1:0] wire_op_c;
    logic        [DATA_WIDTH-1:0] wire_op_o; // computed combinationally

    // SRAM interface signals
    logic        [DATA_WIDTH-1:0] sram_data_in;
    logic                         sram_we;
    logic        [DATA_WIDTH-1:0] sram_addr;
    logic        [DATA_WIDTH-1:0] sram_data_out;

    // Synchronizers for clock domain crossing
    // Synchronize SRAM read data from PCLK (APB) domain to clk_dsp (DSP) domain
    logic [DATA_WIDTH-1:0] sram_data_out_sync;
    // Synchronize DSP result (wire_op_o) from clk_dsp domain back to PCLK domain
    logic [DATA_WIDTH-1:0] wire_op_o_sync;

    //----------------------------------------------------------------------------
    // APB Interface Logic (in PCLK domain)
    //----------------------------------------------------------------------------
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            reg_operand_a  <= 'd0;
            reg_operand_b  <= 'd0;
            reg_operand_c  <= 'd0;
            reg_operand_o  <= 'd0;
            reg_control    <= 'd0;
            reg_wdata_sram <= 'd0;
            reg_addr_sram  <= 'd0;
            PREADY         <= 1'b0;
            PSLVERR        <= 1'b0;
        end
        else if (PSEL && PENABLE) begin
            // Check for valid APB address.
            // Valid addresses: ADDRESS_A, ADDRESS_B, ADDRESS_C, ADDRESS_O,
            // ADDRESS_CONTROL, ADDRESS_WDATA, ADDRESS_SRAM_ADDR.
            // Additionally, for SRAM access (ADDRESS_SRAM_ADDR), ensure reg_addr_sram is within [0,63].
            if ((PADDR == ADDRESS_A) || (PADDR == ADDRESS_B) || (PADDR == ADDRESS_C) ||
                (PADDR == ADDRESS_O) || (PADDR == ADDRESS_CONTROL) || (PADDR == ADDRESS_WDATA) ||
                (PADDR == ADDRESS_SRAM_ADDR)) begin
                if (PADDR == ADDRESS_SRAM_ADDR) begin
                    if (reg_addr_sram > 63) begin
                        PSLVERR <= 1'b1;
                    end
                    else begin
                        PSLVERR <= 1'b0;
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
                        end
                        else begin
                            if (reg_control == SRAM_READ) begin
                                PRDATA <= sram_data_out;
                            end
                            else begin
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
                else begin
                    PSLVERR <= 1'b0;
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