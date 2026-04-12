`timescale 1ps/1ps
module clock_divider_tb();
    localparam CLK_PERIOD = 10;
    // Inputs
    logic clk;
    logic rst_n;
    logic [1:0] sel;

    // Outputs
    logic clk_out;

    // Instantiate the Unit Under Test (UUT)
    clock_divider dut (
        .clk   (clk),
        .rst_n (rst_n),
        .sel   (sel),
        .clk_out(clk_out)
    );

    // Clock generation
    always begin
        clk = 1;
        forever #(CLK_PERIOD/2) clk = ~clk; 
    end

    // Reset assertion
    initial begin
        rst_n = 0;
        #CLK_PERIOD;
        rst_n = 1;
    end

      initial  $dumpfile("test.vcd");
      initial  $dumpvars(0, clock_divider_tb);
    // Monitor
    initial begin
         $monitor("Time=%t, rst_n=%b, clk=%b, sel=%b, clk_out=%b", $time, rst_n, clk, sel, clk_out);
    end
    // Stimulus Dump waves
    initial begin

       #(CLK_PERIOD);
        sel = 2'b00; // clk/2
        #(4*CLK_PERIOD);
        sel = 2'b01; // clk/4
         #(8*CLK_PERIOD);
        sel = 2'b10; // clk/8
         #(16*CLK_PERIOD);
        sel = 2'b11;     
        $finish;
    end

endmodule