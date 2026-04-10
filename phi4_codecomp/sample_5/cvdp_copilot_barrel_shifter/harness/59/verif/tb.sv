module tb_barrel_shifter;
    reg [15:0] data_in;
    reg [3:0] shift_bits;
    reg [1:0] mode;
    reg left_right;
    reg [15:0] mask;
    wire [15:0] data_out;
    wire error;

    barrel_shifter #(.data_width(16), .shift_bits_width(4)) uut (
        .data_in(data_in),
        .shift_bits(shift_bits),
        .mode(mode),
        .left_right(left_right),
        .mask(mask),
        .data_out(data_out),
        .error(error)
    );

    reg [15:0] expected;  // Expected value for comparison

    initial begin
        // Test Logical Shift
        data_in = 16'b1010_1111_0000_1100;
        shift_bits = 4;
        mode = 2'b00;
        left_right = 1;  // Left shift
        expected = 16'b1111_0000_1100_0000;  // Expected output
        #10;
        $display("TEST: Logical Shift Left");
        $display("Inputs: data_in = %b, shift_bits = %d, mode = %b (Logical), left_right = %b", data_in, shift_bits, mode, left_right);
        $display("Expected: %b, Actual: %b", expected, data_out);
        if (data_out === expected)
            $display("Result: PASS\n");
        else
            $display("Result: FAIL (Expected: %b, Got: %b)\n", expected, data_out);

        // Test Arithmetic Shift
        mode = 2'b01;
        left_right = 0;  // Right shift
        expected = 16'b1111_1010_1111_0000;  // Expected output
        #10;
        $display("TEST: Arithmetic Shift Right");
        $display("Inputs: data_in = %b, shift_bits = %d, mode = %b (Arithmetic), left_right = %b", data_in, shift_bits, mode, left_right);
        $display("Expected: %b, Actual: %b", expected, data_out);
        if (data_out === expected)
            $display("Result: PASS\n");
        else
            $display("Result: FAIL (Expected: %b, Got: %b)\n", expected, data_out);

        // Test Rotate
        mode = 2'b10;
        left_right = 1;  // Rotate left
        expected = 16'b1111_0000_1100_1010;  // Expected output
        #10;
        $display("TEST: Rotate Left");
        $display("Inputs: data_in = %b, shift_bits = %d, mode = %b (Rotate), left_right = %b", data_in, shift_bits, mode, left_right);
        $display("Expected: %b, Actual: %b", expected, data_out);
        if (data_out === expected)
            $display("Result: PASS\n");
        else
            $display("Result: FAIL (Expected: %b, Got: %b)\n", expected, data_out);

        // Test Custom Masked Shift
        mode = 2'b11;
        mask = 16'b1111_0000_1111_0000;
        left_right = 0;  // Right shift
        expected = 16'b0000_0000_1111_0000;  // Expected output
        #10;
        $display("TEST: Custom Masked Right Shift");
        $display("Inputs: data_in = %b, shift_bits = %d, mode = %b (Masked), left_right = %b, mask = %b", data_in, shift_bits, mode, left_right, mask);
        $display("Expected: %b, Actual: %b", expected, data_out);
        if (data_out === expected)
            $display("Result: PASS\n");
        else
            $display("Result: FAIL (Expected: %b, Got: %b)\n", expected, data_out);

        // Test Invalid Mode
        mode = 2'bxx;  // Invalid mode
        expected = 16'b0000_0000_0000_0000;  // Expected output
        #10;
        $display("TEST: Invalid Mode");
        $display("Inputs: data_in = %b, shift_bits = %d, mode = %b (Invalid)", data_in, shift_bits, mode);
        $display("Expected: %b, Actual: %b, Error Flag: %b", expected, data_out, error);
        if (data_out === expected && error === 1)
            $display("Result: PASS\n");
        else
            $display("Result: FAIL (Expected: %b, Got: %b, Error: %b)\n", expected, data_out, error);

        $finish;  // End the simulation
    end
endmodule