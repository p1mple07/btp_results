module tb_binary_to_gray;
  parameter WIDTH = 5;

  reg  [WIDTH-1:0] binary_in;  // Binary input
  wire [WIDTH-1:0] gray_out;  // Gray code output

  // Instantiate the Binary to Gray Code Converter
  binary_to_gray #(
      .WIDTH(WIDTH)
  ) uut (
      .binary_in(binary_in),
      .gray_out (gray_out)
  );

  initial begin
    $monitor("Time = %0t | Binary Input = %b | Gray Output = %b", $time, binary_in, gray_out);

    binary_in = 4'b0000;
    #10;
    binary_in = 4'b0001;
    #10;
    binary_in = 4'b0010;
    #10;
    binary_in = 4'b0011;
    #10;
    binary_in = 4'b0100;
    #10;
    binary_in = 4'b0101;
    #10;
    binary_in = 4'b0110;
    #10;
    binary_in = 4'b0111;
    #10;
    binary_in = 4'b1000;
    #10;
    binary_in = 4'b1001;
    #10;

    $display("\n--- Printing Random Values ---\n");


    repeat (16) begin
      binary_in = $urandom % (1 << WIDTH);
      #10;
    end

    $finish;
  end
endmodule