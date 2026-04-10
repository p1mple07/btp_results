module gf_mac_tb;

    // Instantiation 1
    localparam VALID_WIDTH = 32;
    reg [VALID_WIDTH-1:0] a_valid;
    reg [VALID_WIDTH-1:0] b_valid;
    wire [7:0] result_valid;
    wire valid_result_valid;
    wire error_flag_valid;

    gf_mac #(VALID_WIDTH) uut_valid (
        .a(a_valid),
        .b(b_valid),
        .result(result_valid),
        .valid_result(valid_result_valid),
        .error_flag(error_flag_valid)
    );

    // Instantiation 2
    localparam INVALID_WIDTH = 34;
    reg [INVALID_WIDTH-1:0] a_invalid;
    reg [INVALID_WIDTH-1:0] b_invalid;
    wire [7:0] result_invalid;
    wire valid_result_invalid;
    wire error_flag_invalid;

   
    gf_mac #(INVALID_WIDTH) uut_invalid (
        .a(a_invalid),
        .b(b_invalid),
        .result(result_invalid),
        .valid_result(valid_result_invalid),
        .error_flag(error_flag_invalid)
    );
      

    initial begin
        // Test Case 1
        a_valid = {8'h57, 8'h22, 8'h45, 8'h53};
        b_valid = {8'h83, 8'h33, 8'h48, 8'h5F};
        #10;
        $display("Test Case 1");
        $display("a = %h, b = %h, result = %h (Expected: 3F), valid_result = %b (Expected: 1), error_flag = %b (Expected: 0)", 
                 a_valid, b_valid, result_valid, valid_result_valid, error_flag_valid);
        if (error_flag_valid) $display("Test Failed! Error Flag is HIGH.");
        else if (!valid_result_valid) $display("Test Failed! Result is not valid.");
        else if (result_valid !== 8'h3F) $display("Test Failed! Expected %h, got %h", 8'h3F, result_valid);
        else $display("Test Case 1 Passed!");

        // Test Case 2
        a_valid = {8'h22, 8'h53, 8'h57, 8'h45};
        b_valid = {8'h33, 8'h5F, 8'h83, 8'h48};
        #10;
        $display("Test Case 2");
        $display("a = %h, b = %h, result = %h (Expected: 3F), valid_result = %b (Expected: 1), error_flag = %b (Expected: 0)", 
                 a_valid, b_valid, result_valid, valid_result_valid, error_flag_valid);
        if (error_flag_valid) $display("Test Failed! Error Flag is HIGH.");
        else if (!valid_result_valid) $display("Test Failed! Result is not valid.");
        else if (result_valid !== 8'h3F) $display("Test Failed! Expected %h, got %h", 8'h3F, result_valid);
        else $display("Test Case 2 Passed!");

        // Test Case 3:
        a_valid = {VALID_WIDTH{1'b0}};
        b_valid = {VALID_WIDTH{1'b0}};
        #10;
        $display("Test Case 3");
        $display("a = %h, b = %h, result = %h (Expected: 00), valid_result = %b (Expected: 1), error_flag = %b (Expected: 0)", 
                 a_valid, b_valid, result_valid, valid_result_valid, error_flag_valid);
        if (error_flag_valid) $display("Test Failed! Error Flag is HIGH.");
        else if (!valid_result_valid) $display("Test Failed! Result is not valid.");
        else if (result_valid !== 8'h00) $display("Test Failed! Expected %h, got %h", 8'h00, result_valid);
        else $display("Test Case 3 Passed!");

        // Test Case 4
        a_invalid = {INVALID_WIDTH{1'b0}};
        b_invalid = {INVALID_WIDTH{1'b0}};
        #10;
        $display("Test Case 4");
        $display("a = %h, b = %h, result = %h (Expected: 0), valid_result = %b (Expected: 0), error_flag = %b (Expected: 1)", 
                 a_invalid, b_invalid, result_invalid, valid_result_invalid, error_flag_invalid);
        if (!error_flag_invalid) $display("Test Failed! Error flag is LOW for invalid WIDTH.");
        else $display("Test Case 4 Passed!");

        $finish;
    end
endmodule