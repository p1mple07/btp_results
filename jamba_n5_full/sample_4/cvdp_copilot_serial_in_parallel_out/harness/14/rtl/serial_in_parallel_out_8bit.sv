module sipo_top#(parameter DATA_WIDTH = 16, ...);

    crc_generator #(.DATA_WIDTH(DATA_WIDTH), .CRCFW(CRC_WIDTH), .RST(rst), .CLK(clk)) uut_crc (
        .data_in(serial_in_parallel_out_8bit.parallel_out),
        .clk(clk),
        .rst(rst),
        .crc_out(crc_out)
    );

    assign received_crc = crc_out;

    onebit_ecc#(.DATA_WIDTH(DATA_WIDTH), .CODE_WIDTH(CODE_WIDTH)) uut_onebit_ecc1 (
        .data_in(parallel_out),
        .encoded(encoded),
        .received(received),
        .data_out(data_out),
        .error_detected(error_detected),
        .error_corrected(error_corrected)
    );

endmodule
