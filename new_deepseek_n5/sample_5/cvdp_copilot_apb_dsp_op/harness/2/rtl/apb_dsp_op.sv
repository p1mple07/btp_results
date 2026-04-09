Module
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
    input  logic [3:0] PSEL,       // DSP selector
    input  logic                  PENABLE,    // APB enable
    output logic [DATA_WIDTH-1:0] PRDATA,     // Read data
    output logic                  PREADY      // Ready signal
);

    // APB interface logic with dual-flop synchronizer
    logic [DATA_WIDTH-1:0] sram_data_in;
    logic [DATA_WIDTH-1:0] sram_data_out;
    logic [ADDR_WIDTH-1:0] sram_addr;
    logic [1:0]   sram_sel;
    logic [1:0]   sram_valid;

    // Clock selection with dual-flop synchronizer
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            sram_sel <= 0;
            sram_valid <= 1;
        end else if (PENABLE & PSEL) begin
            case (PADDR)
                ADDRESS_A         : sram_sel <= 1;
                ADDRESS_B         : sram_sel <= 1;
                ADDRESS_C         : sram_sel <= 1;
                ADDRESS_O         : sram_sel <= 1;
                ADDRESS_CONTROL   : sram_sel <= 1;
                ADDRESS_WDATA     : sram_sel <= 1;
                ADDRESS_SRAM_ADDR : sram_sel <= 1;
            endcase
            sram_valid <= 1;
        end
    end

    // Synchronize data transfer between APB and SRAM
    always_comb begin
        sram_data_in = (reg_control == SRAM_WRITE) ? reg_wdata_sram : wire_op_o;
        sram_data_out <= sram_valid ? sram_data_in : 0;
    end

    // Internal registers
    logic [DATA_WIDTH-1:0] reg_operand_a;
    logic [DATA_WIDTH-1:0] reg_operand_b;
    logic [DATA_WIDTH-1:0] reg_operand_c;
    logic [DATA_WIDTH-1:0] reg_operand_o;
    logic [DATA_WIDTH-1:0] reg_control;
    logic [DATA_WIDTH-1:0] reg_wdata_sram;
    logic [DATA_WIDTH-1:0] reg_addr_sram;

    // Control modes
    localparam CONTROL_MODES = 32'd1,
        SRAM_WRITE     : 32'd1,
        SRAM_READ      : 32'd2,
        DSP_READ_A      : 32'd3,
        DSP_READ_B      : 32'd4,
        DSP_READ_C      : 32'd5,
        DSP_WRITE_O     : 32'd6;

    // Internal signals
    logic [DATA_WIDTH-1:0] reg_wdata_sram;
    logic [DATA_WIDTH-1:0] reg_addr_sram;

    // APB transaction control
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
            case (reg_control)
                SRAM_READ      : reg_operand_a  <= PWDATA;
                SRAM_READ      : reg_operand_b  <= PWDATA;
                SRAM_READ      : reg_operand_c  <= PWDATA;
                SRAM_READ      : reg_operand_o  <= PWDATA;
                SRAM_WRITE     : reg_wdata_sram <= PWDATA;
                DSP_READ_A      : reg_wdata_sram <= PWDATA;
                DSP_READ_B      : reg_wdata_sram <= PWDATA;
                DSP_READ_C      : reg_wdata_sram <= PWDATA;
                DSP_READ_O      : reg_wdata_sram <= PWDATA;
                SRAM_WRITE     : reg_addr_sram  <= PADDR;
                DSP_READ_A      : reg_addr_sram  <= PADDR;
                DSP_READ_B      : reg_addr_sram  <= PADDR;
                DSP_READ_C      : reg_addr_sram  <= PADDR;
                DSP_READ_O      : reg_addr_sram  <= PADDR;
                default        : reg_addr_sram  <= reg_addr_sram;
            endcase
            if (sram_valid) begin
                sram_data_in = (reg_control == SRAM_WRITE) ? reg_wdata_sram : wire_op_o;
                sram_data_out <= sram_valid ? sram_data_in : 0;
            end else begin
                sram_data_out <= 0;
            end
            PREADY <= 1'b1;
            if (sram_valid) begin
                wire_op_o = (wire_op_a * wire_op_b) + wire_op_c;
            end else begin
                case (reg_control)
                    SRAM_READ      : wire_op_a <= sram_data_out;
                    SRAM_READ      : wire_op_b <= sram_data_out;
                    SRAM_READ      : wire_op_c <= sram_data_out;
                    default        : wire_op_a <= 0;
                    wire_op_b <= 0;
                    wire_op_c <= 0;
                endcase
            end
        end
    end

    // SRAM logic
    always_comb begin
        sram_data_in = (reg_control == SRAM_WRITE) ? reg_wdata_sram : wire_op_o;
        sram_data_out <= sram_valid ? sram_data_in : 0;
    end

    // DSP operation
    always_ff @(posedge clk_dsp) begin
        if (sram_valid) begin
            sram_data_in = (reg_control == SRAM_WRITE) ? reg_wdata_sram : wire_op_o;
            sram_data_out <= sram_valid ? sram_data_in : 0;
        end else begin
            sram_data_out <= 0;
        end
    end

    // DSP operation
    always_ff @(posedge en_clk_dsp) begin
        case (reg_control)
            SRAM_READ      : wire_op_a <= sram_data_out;
            SRAM_READ      : wire_op_b <= sram_data_out;
            SRAM_READ      : wire_op_c <= sram_data_out;
            default        : wire_op_a <= 0;
            wire_op_b <= 0;
            wire_op_c <= 0;
        endcase
    end

    assign wire_op_o = (wire_op_a * wire_op_b) + wire_op_c;

endmodule