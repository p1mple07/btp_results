module apb_dsp_unit (
    pclk,
    presetn,
    paddr,
    pselx,
    penable,
    pwrite,
    pwdata,
    pready,
    prdata,
    slverr
);

    input pclk;
    input presetn;
    input [10:0] paddr;
    input pselx;
    input penable;
    input pwrite;
    input [7:0] pwdata;
    output reg pready;
    output reg [7:0] prdata;
    output reg slverr;

    // Internal registers
    reg [7:0] r_operand_1 = 8'h0;
    reg [7:0] r_operand_2 = 8'h0;
    reg r_Enable = 2'b0;
    reg r_write_address = 16'h00000000;
    reg r_write_data = 8'h0;

    // Memory size
    localparam MEM_SIZE = 1024; // 1 KB
    reg [7:0] mem [MEM_SIZE-1:0];

    // Address mapping
    always @(posedge pclk) begin
        if (presetn) begin
            r_operand_1 <= 8'h0;
            r_operand_2 <= 8'h0;
            r_Enable <= 2'b0;
            r_write_address <= 16'h00000000;
            r_write_data <= 8'h0;
            pready <= 1'b1;
            prdata <= 8'h0;
            slverr <= 1'b0;
        end
    end

    // Read operation
    always @(posedge pclk) begin
        if (penable) begin
            case (pselx)
                0: prdata <= mem[paddr];
                1: slverr <= 1'b0;
                default: slverr <= 1'b1;
            endcase
        end
    end

    // Write operation
    always @(posedge pclk) begin
        if (penable) begin
            case (pselx)
                0: mem[paddr] <= pwdata;
                1: slverr <= 1'b0;
                default: slverr <= 1'b1;
            endcase
        end
    end

    // Operation mode
    always @(posedge pclk) begin
        case (r_Enable)
            0'b0: begin
                slverr <= 1'b0;
                // DSP disabled
            end
            0'b1: begin
                if (pwrite) begin
                    mem[r_write_address] <= r_write_data;
                end
                slverr <= 1'b0;
                // Addition mode
            end
            0'b2: begin
                if (pwrite) begin
                    mem[r_write_address] <= r_write_data;
                end
                slverr <= 1'b0;
                // Multiplication mode
            end
            0'b3: begin
                if (pwrite) begin
                    mem[r_write_address] <= r_write_data;
                end
                slverr <= 1'b0;
                // Data writing mode
            end
            default: slverr <= 1'b1;
        end
    end

    // SRAM interface
    always @(posedge pclk) begin
        if (pwrite) begin
            if (paddr >= 16'h0000 && paddr <= 16'h0005) begin
                slverr <= 1'b0;
            end else begin
                slverr <= 1'b1;
            end
        end
    end

endmodule
