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
    input  logic                  PWRITE,     // Write/Read enable
    input  logic [DATA_WIDTH-1:0] PWDATA,     // Write data
    input  logic                  PSEL,       // DSP selector
    input  logic                  PENABLE,    // APB enable
    output logic [DATA_WIDTH-1:0] PRDATA,     // Read data
    output logic                  PREADY      // Ready signal
);

    // ------------------------------------------------------------
    // 1. Clock Domain Crossing Protection
    // ------------------------------------------------------------
    localparam ADDR_RANGE = ADDR_WIDTH * 2;
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            sram_data_in  <= '0;
            sram_data_out <= '0;
            PREADY        <= 1'b0;
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
                if (reg_control == SRAM_WRITE) begin
                    sram_we         <= 1'b1;
                end else begin
                    sram_we         <= 1'b0;
                end

                case (reg_control)
                    DSP_READ_OP_A  : sram_addr  = reg_operand_a;
                    DSP_READ_OP_B  : sram_addr  = reg_operand_b;
                    DSP_READ_OP_C  : sram_addr  = reg_operand_c;
                    DSP_WRITE_OP_O : sram_addr  = reg_operand_o;
                    default           : sram_addr  = reg_addr_sram;
                endcase
            end
        end
    end

    // ------------------------------------------------------------
    // 2. APB Address Validation
    // ------------------------------------------------------------
    always_comb begin
        if (PADDR >= ADDR_MASK) begin
            PSLVERR <= 1'b1;
        end else begin
            PSLVERR <= 1'b0;
        end
    end

    // ------------------------------------------------------------
    // 3. APB Transaction Synchronization
    // ------------------------------------------------------------
    logic [DATA_WIDTH-1:0] sram_data_in, sram_data_out;
    logic [DATA_WIDTH-1:0] reg_operand_a, reg_operand_b, reg_operand_c, reg_operand_o;

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
        end else if (PENABLE & PSEL) begin
            PREADY <= 1'b1;
            if (PWRITE) begin
                reg_operand_a  <= PWDATA;
                reg_operand_b  <= PWDATA;
                reg_operand_c  <= PWDATA;
                reg_operand_o  <= PWDATA;
                reg_control    <= PWDATA;
                reg_wdata_sram <= PWDATA;
                reg_addr_sram  <= PWDATA;
            end else begin
                if (reg_control == SRAM_WRITE) begin
                    sram_we         <= 1'b1;
                end else begin
                    sram_we         <= 1'b0;
                end

                case (reg_control)
                    DSP_READ_OP_A  : sram_addr  = reg_operand_a;
                    DSP_READ_OP_B  : sram_addr  = reg_operand_b;
                    DSP_READ_OP_C  : sram_addr  = reg_operand_c;
                    DSP_WRITE_OP_O : sram_addr  = reg_operand_o;
                    default           : sram_addr  = reg_addr_sram;
                endcase
            end
        end
    end

    // ------------------------------------------------------------
    // 4. Read Data from SRAM
    // ------------------------------------------------------------
    always_ff @(posedge PCLK) begin
        if (sram_we) begin
            mem[sram_addr] <= sram_data_in;
        end else begin
            sram_data_out <= mem[sram_addr];
        end
    end

    // ------------------------------------------------------------
    // 5. DSP Operation Logic
    // ------------------------------------------------------------
    always_ff @(posedge dsp_clk_sel) begin
        case (reg_control)
            DSP_READ_OP_A  : wire_op_a <= sram_data_out;
            DSP_READ_OP_B  : wire_op_b <= sram_data_out;
            DSP_READ_OP_C  : wire_op_c <= sram_data_out;
        endcase
    end

    assign wire_op_o = (wire_op_a * wire_op_b) + wire_op_c;

    // ------------------------------------------------------------
    // 6. Output Signals
    // ------------------------------------------------------------
    assign PRDATA        = wire_op_o;
    assign PREADY        = PREADY;
    assign PSLVERR       = PSLVERR;

endmodule
