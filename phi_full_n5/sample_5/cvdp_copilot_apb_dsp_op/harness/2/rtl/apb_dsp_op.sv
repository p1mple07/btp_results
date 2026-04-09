module apb_dsp_op #(
    parameter ADDR_WIDTH = 'd8,
    parameter DATA_WIDTH = 'd32
) (
    input  logic                  clk_dsp,    // Faster clock to DSP operation
    input  logic                  en_clk_dsp,    // Enable faster DSP clock
    input  logic                  PCLK,         // APB clock
    input  logic                  PRESETn,       // Active low asynchronous APB Reset
    input  logic [ADDR_WIDTH-1:0] PADDR,      // APB address
    input  logic                  PWRITE,        // Write/Read enable
    input  logic [DATA_WIDTH-1:0] PWDATA,     // Write data
    input  logic                  PSEL,          // DSP selector
    input  logic                  PENABLE,       // APB enable
    output logic [DATA_WIDTH-1:0] PRDATA,     // Read data
    output logic                  PREADY,        // Ready signal
    output logic PSLVERR           // Error signal
);

    // Clock domain crossing synchronizer
    logic sync_clk_dsp, sync_PCLK;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            sync_clk_dsp = PCLK;
            sync_PCLK = en_clk_dsp;
        end
    end

    // Interface logic
    always_comb begin
        PSLVERR = (PSEL && PENABLE && (PADDR < ADDR_WIDTH || PADDR > ADDR_WIDTH + ADDR_WIDTH - 1)) begin
            PSLVERR = 1'b1;
        end else begin
            PSLVERR = 1'b0;
        end
    end

    // Synchronized registers
    logic [DATA_WIDTH-1:0] reg_operand_a = 'd0;
    logic [DATA_WIDTH-1:0] reg_operand_b = 'd0;
    logic [DATA_WIDTH-1:0] reg_operand_c = 'd0;
    logic [DATA_WIDTH-1:0] reg_operand_o = 'd0;
    logic [DATA_WIDTH-1:0] reg_control;
    logic [DATA_WIDTH-1:0] reg_wdata_sram = 'd0;
    logic [DATA_WIDTH-1:0] reg_addr_sram = 'd0;

    always_ff @(posedge sync_clk_dsp) begin
        if (!PRESETn) begin
            reg_operand_a <= 'd0;
            reg_operand_b <= 'd0;
            reg_operand_c <= 'd0;
            reg_operand_o <= 'd0;
            reg_control    <= 'd0;
            reg_wdata_sram <= 'd0;
            reg_addr_sram  <= 'd0;
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
                PSLVERR <= (PSEL && PENABLE && (PADDR < ADDR_WIDTH || PADDR > ADDR_WIDTH + ADDR_WIDTH - 1)) ? 1'b1 : 1'b0;
            end
        end
    end

    // SRAM logic
    logic [DATA_WIDTH-1:0] mem [63:0];

    always_comb begin
        sram_data_in = (reg_control == SRAM_WRITE) ? reg_wdata_sram : wire_op_o;

        if ((reg_control == SRAM_WRITE) || (reg_control == DSP_WRITE_OP_O)) begin
            sram_we = 1'b1;
        end else begin
            sram_we = 1'b0;
        end

        case (reg_control)
            DSP_READ_OP_A  : sram_addr = reg_operand_a;
            DSP_READ_OP_B  : sram_addr = reg_operand_b;
            DSP_READ_OP_C  : sram_addr = reg_operand_c;
            DSP_WRITE_OP_O : sram_addr = reg_operand_o;
            default        : sram_addr = reg_addr_sram;
        endcase
    end

    always_ff @(posedge sync_clk_dsp) begin
        if (sram_we) begin
            mem[sram_addr] <= sram_data_in;
        end else begin
            sram_data_out <= mem[sram_addr];
        end
    end

    // DSP operation
    always_ff @(posedge clk_dsp) begin
        case (reg_control)
            DSP_READ_OP_A  : wire_op_a <= sram_data_out;
            DSP_READ_OP_B  : wire_op_b <= sram_data_out;
            DSP_READ_OP_C  : wire_op_c <= sram_data_out;
        endcase
    end

    assign wire_op_o = (wire_op_a * wire_op_b) + wire_op_c;

endmodule
