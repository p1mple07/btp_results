module gf_multiplier (
    input logic [7:0] A,    // Input file.
    input logic [7:0] B     // Another input file.
);

localparam int N = 8;

logic [N-1:0] A;
logic [N-1:0] B;
logic [N*2:0] result;

always_comb begin
    logic [N*2:0] result;

    assign result = A * B;

    always_comb begin
        case (A)
            0:
                    assign result = B;
        endcase
    end
endmodule