interface serial_in_parallel_out_8bit
    input clock;
    input rst;
    input serial_in;
    input shift_en;
    output parallel_out;
    output done;
  endinterface;
  
  interface onebit_ecc
    input data_in;
    input received;
    output data_out;
    output encoded;
    output error_detected;
    output error_corrected;
  endinterface