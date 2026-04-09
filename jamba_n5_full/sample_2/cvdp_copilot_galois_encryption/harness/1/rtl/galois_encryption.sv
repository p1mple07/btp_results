`include "rtl/galois_encryption.sv"

class testbench;
    parameter TESTS = 3;

    rand int testid;
    int test_num;

    task start;
        testid = rand int {4, 8};
        test_num = testid % TESTS;
        $display("Test %0d started", test_num);
        run_test();
    endtask

    task run_test;
        integer i, j;
        int data_in_bytes[4][4];
        integer data_out_bytes[4][4];
        int key = 32'h1c598438;

        // Test Case 1: Full encryption
        data_in_bytes[0][0] = 32'h00000000;
        data_in_bytes[0][1] = 32'h00000000;
        data_in_bytes[0][2] = 32'h00000000;
        data_in_bytes[0][3] = 32'h00000000;
        data_in_bytes[1][0] = 32'h00000000;
        data_in_bytes[1][1] = 32'h00000000;
        data_in_bytes[1][2] = 32'h00000000;
        data_in_bytes[1][3] = 32'h00000000;
        data_in_bytes[2][0] = 32'h00000000;
        data_in_bytes[2][1] = 32'h00000000;
        data_in_bytes[2][2] = 32'h00000000;
        data_in_bytes[2][3] = 32'h00000000;
        data_in_bytes[3][0] = 32'h00000000;
        data_in_bytes[3][1] = 32'h00000000;
        data_in_bytes[3][2] = 32'h00000000;
        data_in_bytes[3][3] = 32'h00000000;

        data_out_bytes[0][0] = 32'h00000000;
        data_out_bytes[0][1] = 32'h00000000;
        data_out_bytes[0][2] = 32'h00000000;
        data_out_bytes[0][3] = 32'h00000000;
        data_out_bytes[1][0] = 32'h00000000;
        data_out_bytes[1][1] = 32'h00000000;
        data_out_bytes[1][2] = 32'h00000000;
        data_out_bytes[1][3] = 32'h00000000;
        data_out_bytes[2][0] = 32'h00000000;
        data_out_bytes[2][1] = 32'h00000000;
        data_out_bytes[2][2] = 32'h00000000;
        data_out_bytes[2][3] = 32'h00000000;
        data_out_bytes[3][0] = 32'h00000000;
        data_out_bytes[3][1] = 32'h00000000;
        data_out_bytes[3][2] = 32'h00000000;
        data_out_bytes[3][3] = 32'h00000000;

        simulate_encryption(key, data_in_bytes, data_out_bytes);
        check_output(data_out_bytes, 4, 4, "Encryption");

        // Test Case 2: Decryption
        data_in_bytes[0][0] = 32'h00000000;
        data_in_bytes[0][1] = 32'h00000000;
        data_in_bytes[0][2] = 32'h00000000;
        data_in_bytes[0][3] = 32'h00000000;
        data_in_bytes[1][0] = 32'h00000000;
        data_in_bytes[1][1] = 32'h00000000;
        data_in_bytes[1][2] = 32'h00000000;
        data_in_bytes[1][3] = 32'h00000000;
        data_in_bytes[2][0] = 32'h00000000;
        data_in_bytes[2][1] = 32'h00000000;
        data_in_bytes[2][2] = 32'h00000000;
        data_in_bytes[2][3] = 32'h00000000;
        data_in_bytes[3][0] = 32'h00000000;
        data_in_bytes[3][1] = 32'h00000000;
        data_in_bytes[3][2] = 32'h00000000;
        data_in_bytes[3][3] = 32'h00000000;

        data_out_bytes[0][0] = 32'h00000000;
        data_out_bytes[0][1] = 32'h00000000;
        data_out_bytes[0][2] = 32'h00000000;
        data_out_bytes[0][3] = 32'h00000000;
        data_out_bytes[1][0] = 32'h00000000;
        data_out_bytes[1][1] = 32'h00000000;
        data_out_bytes[1][2] = 32'h00000000;
        data_out_bytes[1][3] = 32'h00000000;
        data_out_bytes[2][0] = 32'h00000000;
        data_out_bytes[2][1] = 32'h00000000;
        data_out_bytes[2][2] = 32'h00000000;
        data_out_bytes[2][3] = 32'h00000000;
        data_out_bytes[3][0] = 32'h00000000;
        data_out_bytes[3][1] = 32'h00000000;
        data_out_bytes[3][2] = 32'h00000000;
        data_out_bytes[3][3] = 32'h00000000;

        data_out_bytes[0][0] ^= 32'h1c598438;
        data_out_bytes[0][1] ^= 32'h1c598438;
        data_out_bytes[0][2] ^= 32'h1c598438;
        data_out_bytes[0][3] ^= 32'h1c598438;
        data_out_bytes[1][0] ^= 32'h1c598438;
        data_out_bytes[1][1] ^= 32'h1c598438;
        data_out_bytes[1][2] ^= 32'h1c598438;
        data_out_bytes[1][3] ^= 32'h1c598438;
        data_out_bytes[2][0] ^= 32'h1c598438;
        data_out_bytes[2][1] ^= 32'h1c598438;
        data_out_bytes[2][2] ^= 32'h1c598438;
        data_out_bytes[2][3] ^= 32'h1c598438;
        data_out_bytes[3][0] ^= 32'h1c598438;
        data_out_bytes[3][1] ^= 32'h1c598438;
        data_out_bytes[3][2] ^= 32'h1c598438;
        data_out_bytes[3][3] ^= 32'h1c598438;

        simulate_decryption(key, data_in_bytes, data_out_bytes);
        check_output(data_out_bytes, 4, 4, "Decryption");

        // Test Case 3: Invalid input
        data_in_bytes[0][0] = 32'hFFFFFFFF;
        data_in_bytes[0][1] = 32'hFFFFFFFF;
        data_in_bytes[0][2] = 32'hFFFFFFFF;
        data_in_bytes[0][3] = 32'hFFFFFFFF;
        data_in_bytes[1][0] = 32'hFFFFFFFF;
        data_in_bytes[1][1] = 32'hFFFFFFFF;
        data_in_bytes[1][2] = 32'hFFFFFFFF;
        data_in_bytes[1][3] = 32'hFFFFFFFF;
        data_in_bytes[2][0] = 32'hFFFFFFFF;
        data_in_bytes[2][1] = 32'hFFFFFFFF;
        data_in_bytes[2][2] = 32'hFFFFFFFF;
        data_in_bytes[2][3] = 32'hFFFFFFFF;
        data_in_bytes[3][0] = 32'hFFFFFFFF;
        data_in_bytes[3][1] = 32'hFFFFFFFF;
        data_in_bytes[3][2] = 32'hFFFFFFFF;
        data_in_bytes[3][3] = 32'hFFFFFFFF;

        simulate_encryption(key, data_in_bytes, data_out_bytes);
        check_output(data_out_bytes, 4, 4, "Invalid input - no change");
    endtask

endclass
