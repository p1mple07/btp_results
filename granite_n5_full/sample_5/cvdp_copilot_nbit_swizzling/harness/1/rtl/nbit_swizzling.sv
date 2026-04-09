module nbit_swizzling #(
    parameter DATA_WIDTH=64
) (
    input wire [DATA_WIDTH-1:0] data_in,
    input wire [1:0] sel,
    output reg [DATA_WIDTH-1:0] data_out
);
    always @(*) begin
        if (sel == 0) begin
            data_out = ~data_in; // Reverse entire input
        end else if (sel == 1) begin
            data_out = {~data_in[DATA_WIDTH/2-1:0], data_in[DATA_WIDTH-1:DATA_WIDTH/2]}; // Reverse first half
        end else if (sel == 2) begin
            data_out = {{~data_in[DATA_WIDTH-1:DATA_WIDTH/2], data_in[DATA_WIDTH/2-1:0]}, 
                        ~data_in[DATA_WIDTH/4-1:0], data_in[DATA_WIDTH/2:DATA_WIDTH/4]}; // Reverse second and third sections
        end else if (sel == 3) begin
            data_out = {{~data_in[DATA_WIDTH-1:DATA_WIDTH/4], data_in[DATA_WIDTH/4-1:0]}, 
                        {{~data_in[DATA_WIDTH/2-1:0], data_in[DATA_WIDTH/4:DATA_WIDTH/2]}, 
                            ~data_in[DATA_WIDTH/8-1:0], data_in[DATA_WIDTH/4:DATA_WIDTH/8]}}}; // Reverse fourth and fifth sections
        end else begin
            data_out = data_in; // Default behavior
        end
    end
endmodule