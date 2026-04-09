module serial_in_parallel_out_8bit (
    input wire clk,
    input wire rst,
    input wire sin,
    input wire shift_en,
    output logic done,
    output logic [$clog2(DATA_WIDTH+1)-1:0] parallel_out
);

  parameter CODE_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH + 1);

  //... (code remains unchanged)

endmodule

module oobit_ecc (
    input wire [DATA_WIDTH-1:0] data_in,
    input wire [CODE_WIDTH-1:0] received,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic [CODE_WIDTH-1:0] encoded,
    output logic error_detected,
    output logic error_corrected
);

  //... (code remains unchanged)

endmodule