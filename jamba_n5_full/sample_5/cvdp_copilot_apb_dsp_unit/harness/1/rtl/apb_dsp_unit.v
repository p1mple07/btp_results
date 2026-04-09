module apb_dsp_unit (
    input pclk,
    input presetn,
    input [9:0] paddr,
    input pselx,
    input penable,
    input pwrite,
    input pwdata,
    input prdata,
    input pslverr
);

reg [9:0] r_operand_1;
reg [9:0] r_operand_2;
reg [9:0] r_Enable;
reg [9:0] r_write_address;
reg [9:0] r_write_data;
localparam R_ENABLE_ADD = 3'd2;
localparam R_ENABLE_MUL = 3'd3;
localparam R_ENABLE_DISABLE = 3'd0;

always @(posedge pclk or posedge presetn) begin
    if (presetn) begin
        r_operand_1 <= 0;
        r_operand_2 <= 0;
        r_Enable <= R_ENABLE_DISABLE;
        r_write_address <= 0;
        r_write_data <= 0;
        r_write_data <= 0;
    end else begin
        // Handle normal operation
    end
end

always @(*) begin
    if (r_Enable == R_ENABLE_ADD) begin
        r_operand_1 <= paddr[10:1];
        r_operand_2 <= paddr[0:0];
    end else if (r_Enable == R_ENABLE_MUL) begin
        r_operand_1 <= paddr[10:1];
        r_operand_2 <= paddr[0:0];
    end else if (r_Enable == R_ENABLE_DISABLE) begin
        r_write_address <= paddr[10:1];
    end else if (r_Enable == R_ENABLE_WRITE) begin
        r_write_data <= pwdata;
    end
end

always @(posedge pclk) begin
    if (penable) begin
        // Read operation
        if (pselx == 1'b1) begin
            prdata <= r_operand_1[31:0]; // Assuming address 0x0, but we don't know the address size.
        end else if (pselx == 1'b0) begin
            prdata <= 8'h00;
        end
        pready <= 1'b1;
    end else if (pwrite) begin
        // Write operation
        if (paddr == r_write_address) begin
            pwdata <= r_write_data;
            prdata <= r_write_data;
        end
    end
end

assign pslverr = pslverr_in; // Not defined, but maybe we don't need it.

endmodule
