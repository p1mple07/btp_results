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
    input  logic [DATA_WIDTH-1:0] Psel,       // DSP selector
    input  logic [DATA_WIDTH-1:0] PENABLE,    // APB enable
    output logic [DATA_WIDTH-1:0] PRDATA,     // Read data
    output logic PREADY            // Ready signal
);

    // Clock synchronizer
    logic clock_enable;
    logic clock_sclk;

    // Clock enable signal
    always_ff @(posedge en_clk_dsp) begin
        clock_enable <= 1;
    end

    // Synchronize clock to DSP domain
    always_ff @(posedge PCLK or negedge clock_enable) begin
        if (!clock_enable) begin
            clock_sclk <= 0;
        end else begin
            if (clk_dsp) begin
                clock_sclk <= 1;
            end else begin
                clock_sclk <= 0;
            end
        end
    end

    // Clock selection
    assign dsp_clk_sel = clock_sclk;

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
    localparam DSP_READ_A     = 32'd3;
    localparam DSP_READ_B     = 32'd4;
    localparam DSP_READ_C     = 32'd5;
    localparam DSP_WRITE_O     = 32'd6;

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

    // APB interface logic
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
            end
        end
    end

    // SRAM logic
    logic [DATA_WIDTH-1:0] mem [63:0];

    always_comb begin
        sram_data_in = (reg_control == SRAM_WRITE) ? reg_wdata_sram : wire_op_o;

        if ((reg_control == SRAM_WRITE) || (reg_control == DSP_WRITE_O)) begin
            sram_we = 1'b1;
        end else begin
            sram_we = 1'b0;
        end

        case (reg_control)
            DSP_READ_A  : sram_addr = reg_operand_a;
            DSP_READ_B  : sram_addr = reg_operand_b;
            DSP_READ_C  : sram_addr = reg_operand_c;
            DSP_WRITE_O : sram_addr = reg_operand_o;
            default     : sram_addr = reg_addr_sram;
        endcase
    end

    // DSP operation
    always_ff @(posedge PCLK) begin
        case (reg_control)
            DSP_READ_A  : wire_op_a <= sram_data_out;
            DSP_READ_B  : wire_op_b <= sram_data_out;
            DSP_READ_C  : wire_op_c <= sram_data_out;
        endcase
    end

    // DSP output
    always_comb begin
        wire_op_o = (wire_op_a * wire_op_b) + wire_op_c;
    end

    // APB transaction control
    always_comb begin
        if (PSEL & PENABLE) begin
            if (PADDR & ~valid_address) begin
                PSLVERR = 1'b1;
            end else begin
                PSLVERR = 1'b0;
            end
        end else begin
            PSLVERR = 1'b0;
        end
    end

    // Initialize PREADY and PSLVERR
    always_comb begin
        if (PSEL & PENABLE) begin
            PREADY <= 1'b1;
            PSLVERR <= 1'b0;
        end else begin
            PREADY <= 1'b0;
            PSLVERR <= 1'b0;
        end
    end