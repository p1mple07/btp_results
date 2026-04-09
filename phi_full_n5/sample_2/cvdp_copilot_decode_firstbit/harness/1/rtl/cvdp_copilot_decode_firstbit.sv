module first_bit_decoder #(
    parameter INWIDTH_g = 32,
    parameter INREG_g = 1,
    parameter OUTREG_g = 1,
    parameter PLREGS_g = 1
)(
    input wire clk,
    input wire rst,
    input wire [INWIDTH_g-1:0] in_data,
    input wire in_valid,
    output reg [$clog2(INWIDTH_g)-1:0] out_first_bit,
    output reg out_found,
    output reg out_valid
);

    // Pipeline registers
    reg [$clog2(INWIDTH_g)-1:0] pipeline_stage[PLREGS_g-1:0];

    // Control signals
    reg pipeline_stages_full;

    // Internal pipeline logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out_first_bit <= 0;
            out_found <= 0;
            out_valid <= 0;
            pipeline_stage <= {INWIDTH_g{0}};
            pipeline_stages_full <= 0;
        end else begin
            if (in_valid) begin
                pipeline_stage[0] <= in_data;
                pipeline_stages_full <= PLREGS_g;
            end else begin
                pipeline_stage <= pipeline_stage[PLREGS_g-1];
            end

            if (PLREGS_g == 0) begin
                pipeline_stage[PLREGS_g-1] <= in_data;
                out_first_bit <= $clog2(INWIDTH_g) - 1;
                out_found <= in_data[0] & pipeline_stage[0];
                out_valid <= in_valid & out_found;
            end else begin
                if (pipeline_stages_full) begin
                    pipeline_stage[PLREGS_g-1] <= pipeline_stage[PLREGS_g-2];
                    pipeline_stages_full <= 0;
                end

                if (in_data[0] & pipeline_stage[PLREGS_g-1]) begin
                    out_first_bit <= $clog2(INWIDTH_g) - PLREGS_g;
                    out_found <= 1;
                    out_valid <= in_valid & out_found;
                end
            end
        end
    end

    // Output logic
    always @(posedge clk) begin
        if (INREG_g) begin
            in_valid <= in_valid;
        end

        if (OUTREG_g) begin
            out_first_bit <= out_first_bit;
            out_found <= out_found;
            out_valid <= out_valid;
        end
    end

endmodule
