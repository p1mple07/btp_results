module first_bit_decoder #(
    parameter IN_WIDTH_G = 32,
    parameter IN_REG_G = 1,
    parameter OUT_REG_G = 1,
    parameter PL_REGS_G = 1
)(
    input clk,
    input rst_n,
    input in_data,
    input in_valid,
    output first_bit,
    output found,
    output valid
);

    // Internal variables
    reg [PL_REGS_G-1:0] pipeline_registers;
    reg [IN_WIDTH_G-1:0] temp;

    // Process each pipeline stage
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            first_bit <= 1'b0;
            found <= 1'b0;
            valid <= 1'b0;
            pipeline_registers <= {IN_WIDTH_G*{1'b0}}; // zero array
        end else begin
            // Pass data through pipeline
            temp <= {in_data[IN_WIDTH_G-1:0]};
            pipeline_registers = temp;
        end
    end

    // Detect first set bit
    always @(*) begin
        first_bit = 1'b0;
        found = 1'b0;
        valid = 1'b0;
        for (int i = 0; i < PL_REGS_G; i++) begin
            if (pipeline_registers[i] != 0) begin
                first_bit <= i;
                found <= 1'b1;
                break;
            end
        end
        if (!found) first_bit <= 1'b0;
    end

    assign first_bit = first_bit;
    assign found = found;
    assign valid = valid;

endmodule
