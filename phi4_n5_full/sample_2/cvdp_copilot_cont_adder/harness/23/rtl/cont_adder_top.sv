rtl/cont_adder_top.sv
--------------------------------------------------
module continuous_adder #(
    parameter DATA_WIDTH         = 32,                   // Bit-width for data
    parameter THRESHOLD_VALUE_1  = 50,                   // First threshold value (default: 50)
    parameter THRESHOLD_VALUE_2  = 100,                  // Second threshold value (default: 100)
    parameter SIGNED_INPUTS      = 1,                    // 1 = signed arithmetic, 0 = unsigned arithmetic
    parameter WEIGHT             = 1,                    // Multiplicative weight for input data
    parameter ACCUM_MODE         = 0                     // 0: Threshold-Based Continuous Accumulation, 
                                                           //    1: Window-Based Accum