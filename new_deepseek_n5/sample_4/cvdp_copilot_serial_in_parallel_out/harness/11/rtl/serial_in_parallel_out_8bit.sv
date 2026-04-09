module sipo_top (input clock, rst(1-bit), serial_in, shift_en, output reg [15:0] data_out, output reg [20:0] encoded, output reg error_detected, output reg error_corrected);
  
  // Initialize outputs to zero when reset is high
  always @(rst)  
    begin  
      data_out <= 0;  
      encoded <= 0;  
      error_detected <= 0;  
      error_corrected <= 0;  
    end  
  
  // Connect the serial_in_parallel_out_8bit module
  serial_in_parallel_out_8bit (clock, serial_in, shift_en,  
                               output reg [15:0] parallel_out,  
                               done, data_out, encoded,  
                               error_detected, error_corrected);  
endmodule