module gf_mac #(
    parameter WIDTH = 32  // Input width, should be a multiple of 8
)(
    input  [WIDTH-1:0] a,              
    input  [WIDTH-1:0] b,             
    output [7:0]       result,        
    output             valid_result,  
    output             error_flag      
);

    localparam WIDTH_VALID = (WIDTH % 8 == 0);
    assign error_flag    = !WIDTH_VALID;
    assign valid_result  = WIDTH_VALID;

    wire [7:0] computed_result;

    assign result = WIDTH_VALID ? computed_result : 8'b0;

    generate
        if (WIDTH_VALID) begin : valid_width
            integer i;
            reg [7:0] temp_result;
            wire [7:0] partial_results [(WIDTH/8)-1:0];

            genvar j;
            for (j = 0; j < WIDTH/8; j = j + 1) begin : segment_mult
                gf_multiplier segment_mult_inst (
                    .A(a[(j+1)*8-1:j*8]),
                    .B(b[(j+1)*8-1:j*8]),
                    .result(partial_results[j])
                );
            end

            always @(*) begin
                temp_result = 8'b0;
                for (i = 0; i < WIDTH/8; i = i + 1) begin
                    temp_result = temp_result ^ partial_results[i];
                end
            end

            assign computed_result = temp_result;
        end else begin : invalid_width
            assign computed_result = 8'b0; 
        end
    endgenerate

endmodule


module gf_multiplier (
    input [7:0] A,
    input [7:0] B,
    output reg [7:0] result
);
    reg [7:0] temp_result;
    reg [8:0] multiplicand;
    reg [8:0] irreducible_poly = 9'b100011011; 

    integer i;

    always @(*) begin
        temp_result = 8'b00000000;
        multiplicand = {1'b0, A};
        for (i = 0; i < 8; i = i + 1) begin
            if (B[i]) begin
                temp_result = temp_result ^ multiplicand[7:0];
            end
            multiplicand = multiplicand << 1;
            if (multiplicand[8]) begin
                multiplicand = multiplicand ^ irreducible_poly;
            end
        end
        result = temp_result;
    end
endmodule