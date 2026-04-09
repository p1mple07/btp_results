module sorting_engine #(
    parameter WIDTH = 8,
    parameter N = 8
)(
    input wire clk,
    input wire rst,
    input wire start,
    input [N*WIDTH-1:0] in_data,
    output [N*WIDTH-1:0] out_data
);

    localparam num_elements = N;
    localparam total_passes = N * (N - 1);

    reg [N*WIDTH-1:0] arr;
    reg [0: total_passes-1] current_pass;
    reg sorted;
    reg done;

    always @(posedge clk or negedge rst) begin
        if (rst) begin
            arr <= {N*WIDTH{1'b0}};
            current_pass = 0;
            sorted = 1'b0;
            done = 1'b0;
        end else begin
            if (start) begin
                current_pass = 0;
                sorted = 1'b0;
                done = 1'b0;
                for (current_pass = 0; current_pass < total_passes; current_pass = current_pass + 1) begin
                    sorted = 1'b0;
                    for (instr = 0; instr < N-1; instr = instr + 1) begin
                        if (arr[instr] > arr[instr+1]) begin
                            arr[instr] <= arr[instr+1];
                            arr[instr+1] <= arr[instr];
                        end else begin
                            sorted = 1'b1;
                        end
                    end
                end
                out_data = arr;
                done = 1'b1;
            end else begin
                out_data = arr;
                done = 1'b0;
            end
        end
    end

endmodule
