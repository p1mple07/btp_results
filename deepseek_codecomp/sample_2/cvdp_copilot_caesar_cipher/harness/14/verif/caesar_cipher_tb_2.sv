`timescale 1ns / 1ps

module caesar_cipher_tb_2;

    // Maximum Parameters
    parameter MAX_PHRASE_WIDTH = 256;  // Maximum width for the phrase (32 characters)
    parameter MAX_PHRASE_LEN = MAX_PHRASE_WIDTH / 8;

    // Testbench signals
    reg [MAX_PHRASE_WIDTH-1:0] input_phrase;
    reg [MAX_PHRASE_LEN * 5 - 1:0] key_phrase;
    wire [MAX_PHRASE_WIDTH-1:0] output_phrase;

    // Temporary reg to store output for display
    reg [MAX_PHRASE_WIDTH-1:0] output_phrase_reg;

    // Instantiate caesar_cipher with maximum parameters
    caesar_cipher #(
        .PHRASE_WIDTH(MAX_PHRASE_WIDTH),
        .PHRASE_LEN(MAX_PHRASE_LEN)
    ) uut (
        .input_phrase(input_phrase),
        .key_phrase(key_phrase),
        .output_phrase(output_phrase)
    );

    
    task display_result(
        input integer dynamic_len,
        input [MAX_PHRASE_WIDTH-1:0] input_p,
        input [MAX_PHRASE_LEN * 5 - 1:0] keys,
        input [MAX_PHRASE_WIDTH-1:0] output_p
    );
        integer i;
        begin
            $display("Input Phrase: ");
            for (i = dynamic_len - 1; i >= 0; i = i - 1) begin  
                $write("%c", input_p[i * 8 +: 8]);
            end
            $display("");
            $display("Key Phrase: ");
            for (i = dynamic_len - 1; i >= 0; i = i - 1) begin  
                $write("%d ", keys[i * 5 +: 5]);
            end
            $display("");
            $display("Output Phrase: ");
            for (i = dynamic_len - 1; i >= 0; i = i - 1) begin  
                $write("%c", output_p[i * 8 +: 8]);
            end
            $display("\n----------------------------");
        end
    endtask

    // Test cases
    initial begin
        // Test Case 1
        input_phrase = "abcd";
        key_phrase = {5'd1, 5'd2, 5'd3, 5'd4};
        #10;
        output_phrase_reg = output_phrase;
        display_result(4, input_phrase, key_phrase, output_phrase_reg);

        // Test Case 2
        input_phrase = "ABCDEFGH";
        key_phrase = {5'd8, 5'd7, 5'd6, 5'd5, 5'd4, 5'd3, 5'd2, 5'd1};
        #10;
        output_phrase_reg = output_phrase;
        display_result(8, input_phrase, key_phrase, output_phrase_reg);

        // Test Case 3
        input_phrase = "xyz";
        key_phrase = {5'd3, 5'd1, 5'd5};
        #10;
        output_phrase_reg = output_phrase;
        display_result(3, input_phrase, key_phrase, output_phrase_reg);

        // Test Case 4
        input_phrase = "a1!@z";
        key_phrase = {5'd3, 5'd1, 5'd0, 5'd0, 5'd5};
        #10;
        output_phrase_reg = output_phrase;
        display_result(5, input_phrase, key_phrase, output_phrase_reg);

        // Test Case 5
        input_phrase = "abcd";
        key_phrase = {5'd1, 5'd2};  // Keys will wrap
        #10;
        output_phrase_reg = output_phrase;
        display_result(4, input_phrase, key_phrase, output_phrase_reg);

        // Test Case 6
        input_phrase = "xyz";
        key_phrase = {5'd3, 5'd5, 5'd7};
        #10;
        output_phrase_reg = output_phrase;
        display_result(3, input_phrase, key_phrase, output_phrase_reg);

        // Test Case 7
        input_phrase = 0;  // Explicit zero-width assignment
        key_phrase = 0;
        #10;
        output_phrase_reg = output_phrase;
        display_result(0, input_phrase, key_phrase, output_phrase_reg);

        // Test Case 8
        input_phrase = "abc";
        key_phrase = {5'd26, 5'd26, 5'd26};
        #10;
        output_phrase_reg = output_phrase;
        display_result(3, input_phrase, key_phrase, output_phrase_reg);

        $finish;
    end

endmodule