module sorting_engine #(
    parameter WIDTH = 8,
    parameter N = 8
)(
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [N*WIDTH-1:0] in_data,
    output logic [N*WIDTH-1:0] out_data,
    output logic done
);

reg [31:0] num_passes;
always @(posedge clk or posedge rst_n) begin
    if (!rst_n) begin
        num_passes = 0;
        out_data <= {repeat(WIDTH) 0};
        done = 0;
    end else begin
        if (start) begin
            if (num_passes > 0) begin
                num_passes = num_passes - 1;
                if (num_passes == 0) begin
                    done = 1;
                end
            end
        end else begin
            // idle state
        end
    end
end

always @(posedge clk) begin
    if (num_passes > 0) begin
        for (int i = 0; i < N-1; i++) begin
            for (int j = 0; j < N-i-1; j++) begin
                if (in_data[j] > in_data[j+1]) begin
                    assign in_data[j] = in_data[j^1];
                    assign in_data[j+1] = in_data[j];
                end
            end
        end
    end else begin
        // done state, we don't process further
    end
end

assign out_data = {repeat(WIDTH) 0}; // but we need to output sorted array.

endmodule
