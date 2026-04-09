module sipo_top #(parameter DATA_WIDTH = 16, CODE_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH+1), SHIFT_DIRECTION = 1);

   parameter WIDTH = 64;
   
   logic clk;
   logic rst;
   logic sin;
   logic shift_en;
   logic done;
   logic [DATA_WIDTH-1:0] parallel_out;
   logic [DATA_WIDTH-1:0] data_out;
   logic [CODE_WIDTH-1:0] encoded;
   logic [CODE_WIDTH-1:0] received;
   logic error_detected;
   logic error_corrected;
   
   // Instantiate the serial_in_parallel_out_8bit module
   serial_in_parallel_out_8bit #(
     .WIDTH(WIDTH)
   ) sipo (
     .clk(clk),
     .rst(rst),
     .sin(sin),
     .shift_en(shift_en),
     .done(done),
     .parallel_out(parallel_out)
   );
   
   // Instantiate the oobit_ecc module
   oobit_ecc #(
     .DATA_WIDTH(DATA_WIDTH),
     .CODE_WIDTH(CODE_WIDTH)
   ) ecc (
     .clk(clk),
     .rst(rst),
     .data_in(parallel_out),
     .received(received),
     .data_out(data_out),
     .encoded(encoded),
     .error_detected(error_detected),
     .error_corrected(error_corrected)
   );
   
   // Define the clock period
   always #5 clk = ~clk;
   
   initial begin
      // Generate a test pattern for testing the functionality of the modules
      clk = 1'b0;
      
      rst = 1'b1;
      sin = 1'b1;
      shift_en = 1'b0;
      
      #10 rst = 1'b0;
      #10 sin = 1'b0;
      #10 sin = 1'b1;
      #10 shift_en = 1'b1;
      #10 shift_en = 1'b0;
      #10 $display("Data Out: %h", data_out);
      
      #100 $finish;
   end
endmodule