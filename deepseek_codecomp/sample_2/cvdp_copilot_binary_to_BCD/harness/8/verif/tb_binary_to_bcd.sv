module tb_binary_to_bcd ();

  // Inputs
  logic [ 7:0] binary_in;
  // Outputs
  logic [11:0] bcd_out;

  // Instantiate the Binary to BCD Converter
  binary_to_bcd uut (
      .binary_in(binary_in),
      .bcd_out  (bcd_out)
  );
 
  task display_result;
    input [7:0] binary;
    input [11:0] bcd;
    begin
      $display("Binary Input: %b (%0d) | BCD Output: %b (%0d)", binary, binary, bcd, {
               bcd[11:8], bcd[7:4], bcd[3:0]});
    end
  endtask


  task check_bcd_range;
    input [11:0] bcd;
    begin
   
      assert (bcd[11:8] <= 4'b1001)
      else $fatal(1, "Error: Hundreds BCD digit out of range (0-9) for BCD output %b", bcd);
      assert (bcd[7:4] <= 4'b1001)
      else $fatal(1, "Error: Tens BCD digit out of range (0-9) for BCD output %b", bcd);
      assert (bcd[3:0] <= 4'b1001)
      else $fatal(1, "Error: Ones BCD digit out of range (0-9) for BCD output %b", bcd);
    end
  endtask

  // Test cases
  initial begin
  
    binary_in = 8'd0;  
    #10;
    display_result(binary_in, bcd_out);
    check_bcd_range(bcd_out);
   
    binary_in = 8'd20;  
    #10;
    display_result(binary_in, bcd_out);
    check_bcd_range(bcd_out);

    binary_in = 8'd99;  
    #10;
    display_result(binary_in, bcd_out);
    check_bcd_range(bcd_out);
    
    binary_in = 8'd128;  
    #10;
    display_result(binary_in, bcd_out);
    check_bcd_range(bcd_out);
  
    binary_in = 8'd255;  
    #10;
    display_result(binary_in, bcd_out);
    check_bcd_range(bcd_out);

    $finish;
  end

endmodule