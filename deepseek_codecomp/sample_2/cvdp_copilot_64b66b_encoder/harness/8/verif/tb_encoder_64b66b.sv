`timescale 1ns/1ps

module tb_encoder_64b66b;

    logic clk_in;
    logic rst_in;
    logic [63:0] encoder_data_in;
    logic [7:0] encoder_control_in;
    logic [65:0] encoder_data_out;

    encoder_64b66b dut (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .encoder_data_in(encoder_data_in),
        .encoder_control_in(encoder_control_in),
        .encoder_data_out(encoder_data_out)
    );

    initial begin
        clk_in = 0;
        forever #5 clk_in = ~clk_in;
    end

    task apply_reset;
        begin
            rst_in = 1;
            #10;
            rst_in = 0;
            #10;
        end
    endtask

    task apply_test_vector(
        input logic [63:0] data,
        input logic [7:0] control
    );
        begin
            encoder_data_in = data;
            encoder_control_in = control;
            #10;
        end
    endtask

    initial begin
        $display("Starting Test...");

        rst_in = 0;
        encoder_data_in = 64'b0;
        encoder_control_in = 8'b0;

        apply_reset;

        $display("Test Case 1");
        apply_test_vector(64'hA5A5A5A5A5A5A5A5, 8'b00000000);
        #10;
        $display("encoder_data_out: %h, Expected: %h", encoder_data_out, {2'b01, 64'hA5A5A5A5A5A5A5A5});

        $display("Test Case 2");
        apply_test_vector(64'hDEADBEEFDEADBEEF, 8'b00000000);
        #10;
        rst_in = 1;
        #10;
        $display("After reset, encoder_data_out: %h, Expected: 66'b0", encoder_data_out);
        #10;
        rst_in = 0;

        $display("Test Case 3");
        apply_test_vector(64'hFFFFFFFFFFFFFFFF, 8'b00001111);
        #10;
        $display("encoder_data_out: %h, Expected: %h", encoder_data_out, {2'b10, 64'b0});

        $display("Test Case 4");
        apply_test_vector(64'h123456789ABCDEF0, 8'b10000001);
        #10;
        $display("encoder_data_out: %h, Expected: %h", encoder_data_out, {2'b10, 64'b0});

        $display("Test Case 5");
        apply_test_vector(64'hA5A5A5A5A5A5A5A5, 8'b11111111);
        #10;
        $display("encoder_data_out: %h, Expected: %h", encoder_data_out, {2'b10, 64'b0});

        $display("Test Case 6");
        apply_test_vector(64'h55555555AAAAAAAA, 8'b01010101);
        #10;
        $display("encoder_data_out: %h, Expected: %h", encoder_data_out, {2'b10, 64'b0});

        $display("Test Complete.");
        $finish;
    end

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0);
    end

endmodule