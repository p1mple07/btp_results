Module instantiation and configuration
module prbs_gen_check#(parameter POLY_LENGTH = 31, parameter POLY_TAP = 3, parameter WIDTH = 16) (
    input clocks,
    input rst,
    input data_in,
    output data_out
);
    // Instantiate PRBS generator
    prbs_gen_check prbs_generator (
        clocks,
        rst,
        data_in = data_in,
        data_out = tmp_data_out
    );

    // Instantiate PRBS checker
    prbs_gen_check prbs_checker (
        clocks,
        rst,
        data_in = tmp_data_in,
        data_out = data_out
    );
endmodule