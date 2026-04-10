module gf_multiplier_tb;

    parameter WIDTH = 32;
    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    wire [7:0] result;
    reg [7:0] expected_result;

    gf_mac #(WIDTH) uut (
        .a(a),
        .b(b),
        .result(result)
    );

    initial begin
        // Corrected Test Case 1
        a = {8'h57, 8'h22, 8'h45, 8'h53};  // Segments: 0x57, 0x22, 0x45, 0x53
        b = {8'h83, 8'h33, 8'h48, 8'h5F};  // Segments: 0x83, 0x33, 0x48, 0x5F
        // expected_result = 0xC1 ^ 0x5C ^ 0xEE ^ 0x4C = 0x3F
        expected_result = 8'h3F;
        #10;
        $display("Test Case 1: a = %h, b = %h, result = %h, expected = %h", a, b, result, expected_result);
        if (result !== expected_result) $display("Error: Expected %h, got %h", expected_result, result);

        // Corrected Test Case 2
        a = {8'h22, 8'h53, 8'h57, 8'h45};  // Segments in different order
        b = {8'h33, 8'h5F, 8'h83, 8'h48};
        // expected_result = 0x5C ^ 0x4C ^ 0xC1 ^ 0xEE = 0x3F
        expected_result = 8'h3F;
        #10;
        $display("Test Case 2: a = %h, b = %h, result = %h, expected = %h", a, b, result, expected_result);
        if (result !== expected_result) $display("Error: Expected %h, got %h", expected_result, result);

        $finish;
    end
endmodule