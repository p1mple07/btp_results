module first_bit_decoder #(parameter InWidth_g = 32, PlRegs_g = 1) (
    input [InWidth_g-1:0] In_Data,
    input In_Valid,
    input Clk,
    input Rst,
    output reg [$clog2(InWidth_g)-1:0] Out_FirstBit,
    output reg Out_Found,
    output reg Out_Valid
);

    // Internal variables
    reg [$clog2(InWidth_g)-1:0] tmp_first_bit;
    reg [PlRegs_g-1:0] pipeline_stages [PlRegs_g-1:0];

    // Pipeline control
    reg pipeline_stage_idx;
    always @(posedge Clk or posedge Rst) begin
        if (Rst) begin
            Out_FirstBit <= 0;
            Out_Found <= 0;
            Out_Valid <= 0;
            pipeline_stage_idx <= 0;
            for (int i = 0; i < PlRegs_g; i++) pipeline_stages[i] <= 0;
        end else begin
            if (pipeline_stage_idx == PlRegs_g-1) begin
                Out_FirstBit <= tmp_first_bit;
                Out_Found <= Out_FirstBit != 0;
                Out_Valid <= 1;
                pipeline_stage_idx <= 0;
            end else begin
                pipeline_stage_idx <= pipeline_stage_idx + 1;
                pipeline_stages[pipeline_stage_idx] <= tmp_first_bit;
            end
        end
    end

    // Pipeline logic
    always @(posedge Clk or posedge In_Valid or posedge Rst) begin
        if (Rst) begin
            tmp_first_bit <= 0;
        end else if (In_Valid) begin
            case (In_Data)
                32'b0: begin
                    tmp_first_bit <= 0;
                end
                default: begin
                    tmp_first_bit <= In_Data[0];
                end
            endcase
        end
    end

    // Registering outputs
    always @(posedge Clk or posedge Rst) begin
        if (Rst) begin
            Out_Found <= 0;
        end else begin
            Out_Found <= tmp_first_bit != 0;
        end
    end

    // Registering pipeline stages
    always @(posedge Clk or posedge Rst) begin
        if (Rst) begin
            for (int i = 0; i < PlRegs_g; i++) pipeline_stages[i] <= 0;
        end else begin
            pipeline_stages[0] <= tmp_first_bit;
            for (int i = 1; i < PlRegs_g; i++) begin
                pipeline_stages[i] <= pipeline_stages[i-1];
            end
        end
    end

endmodule
