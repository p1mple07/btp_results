module gf_mac #(parameter WIDTH = 32)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg [WIDTH-1:0] result
);
    localparam SEGMENT_WIDTH = WIDTH / 8;
    wire [SEGMENT_WIDTH-1:0][7:0] segments_a;
    wire [SEGMENT_WIDTH-1:0][7:0] segments_b;
    wire [SEGMENT_WIDTH-1:0][8:0] segment_products;
    wire [SEGMENT_WIDTH-1:0][8:0] segment_results;
    wire [8:0] temp_result;

    assign segments_a = {{(SEGMENT_WIDTH * 8)-WIDTH{1'b0}}, a} >> ((WIDTH % 8) == 0? 0 : (8 - (WIDTH % 8)));
    assign segments_b = {{(SEGMENT_WIDTH * 8)-WIDTH{1'b0}}, b} >> ((WIDTH % 8) == 0? 0 : (8 - (WIDTH % 8)));

    generate
        genvar i;
        for (i = 0; i < SEGMENT_WIDTH; i = i + 1) begin : mac_segments
            // Instantiate gf_multiplier module to calculate segment products
            gf_multiplier #(
               .WIDTH(8)
            )gf_multiplier_inst (
               .a(segments_a[i]),
               .b(segments_b[i]),
               .result(segment_products[i])
            );

            // Apply polynomial reduction on segment products
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    segment_results[i] <= 8'b0000000;
                end else begin
                    segment_results[i] <= segment_products[i];
                    if (segment_products[i][8]) begin
                        segment_results[i] <= segment_results[i] ^ 9'b100011011;
                    end
                end
            end

            // Combine segment products and results to compute final output
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    temp_result <= 8'b0000000;
                end else begin
                    temp_result <= temp_result ^ segment_results[i];
                }
            end
        end
    endgenerate

    // Use combinational logic to combine segment products and reduce overflow
    assign result = ~({(WIDTH % 8){1'b0}}, temp_result[WIDTH-1:0]);
endmodule