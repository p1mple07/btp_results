module tb_fsm_seq_detector;

  logic clk_in, rst_in, seq_in;
  logic seq_detected;
  
  logic [7:0] Pattern0 = 8'b01001110;
  logic [7:0] Pattern1 = 8'b10100111;
  logic [7:0] Pattern2 = 8'b01001110;
  logic [7:0] Pattern3 = 8'b10011100;
  logic [7:0] Pattern4 = 8'b10011100;
  logic [7:0] Pattern5 = 8'b01010011;
  logic [7:0] Pattern6 = 8'b10010011;
  logic [7:0] Pattern7 = 8'b01111111;
  logic [7:0] Pattern8 = 8'b01001110;
  logic [7:0] Pattern9 = 8'b01010011;
  logic [7:0] Pattern10 = 8'b01001110;
  
  logic [87:0] complete_pat;
  logic start_seq;

  parameter [4:0] Length = 8;
  parameter [Length-1:0] informed_seq = 8'b01001110;

  logic [Length-1:0] seq_shift_reg;
  logic ref_seq_detected;

  fsm_seq_detector dut (
    .clk_in(clk_in), 
    .rst_in(rst_in), 
    .seq_in(seq_in), 
    .seq_detected(seq_detected)
  );
   
  initial clk_in = 1;   

  always #2 clk_in = ~clk_in;
  
  assign complete_pat = { Pattern0, Pattern1, Pattern2, Pattern3, Pattern4, Pattern5, Pattern6, Pattern7, Pattern8, Pattern9, Pattern10 }; 

  integer i;

  initial begin
    seq_in <= 0;
    start_seq <= 0;
    rst_in <= 1;
    
    repeat (3) @(posedge clk_in);
    repeat (2) @(posedge clk_in);
    rst_in <= 0;
    start_seq <= 1;
    for (i = 0; i < 88; i = i + 1) begin
        seq_in <= complete_pat[87 - i];
        @(posedge clk_in);
    end
    repeat (3) @(posedge clk_in);
    $finish;
  end

  // Shift register for sequence detection
  always @(posedge clk_in or posedge rst_in) begin
    if (rst_in)
        seq_shift_reg <= 'd0;
    else
        seq_shift_reg <= {seq_shift_reg[Length-2:0], seq_in};
  end

  // Reference sequence detection
  always_comb begin
      ref_seq_detected = (seq_shift_reg == informed_seq);
  end

  // Display outputs for debugging
  always @(posedge clk_in) begin
      $display("Time: %0t | reset: %b | in: %b | out: %b | ref_detected: %b", 
               $time, rst_in, seq_in, seq_detected, ref_seq_detected);
  end

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0);
  end

endmodule
