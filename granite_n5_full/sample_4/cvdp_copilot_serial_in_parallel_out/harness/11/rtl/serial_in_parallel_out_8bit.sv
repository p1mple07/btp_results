module serial_in_parallel_out_8bit (input wire clk,
                                     input wire sin,
                                     input wire shift_en,
                                     output logic done,
                                     output logic [7:0] parallel_out);
  
  always @(posedge clk)  
    begin
      if (shift_en == 1'b1)  
        begin
          parallel_out[7:1] <= parallel_out[6:0];    
          parallel_out[0] <= sin;  
        end  
      else  
        done <= 1'b1;  
    end  

endmodule

module onebit_ecc (input wire [7:0] data_in,
                    input wire [7:0] received,
                    output logic [7:0] data_out,
                    output logic [7:0] encoded,
                    output logic error_detected,
                    output logic error_corrected);

  // compute parity bits
  assign encoded = {data_in, ^data_in};

  // calculate syndrome for error detection
  assign syndrome = received ^ encoded;

  // correct single-bit errors in the received data
  assign error_corrected = received & syndrome;

  // detect if an error was detected in the received data
  assign error_detected = syndrome & ~received;

  // calculate corrected data
  assign data_out = error_corrected? received : encoded;

endmodule