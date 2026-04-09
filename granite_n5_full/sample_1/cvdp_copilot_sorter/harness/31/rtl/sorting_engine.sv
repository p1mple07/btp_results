Here is how the sorting engine module is supposed to work.

verilog code.

module sorting_engine #(N = 8, WIDTH = 8) (
    input  wire                clk,
    input  wire                rst,
    input  wire                start,
    input  wire [N*WIDTH-1]   in_data,
    output reg                done,
    output reg [N*WIDTH-1]   out_data,
    output reg [N*WIDTH-1]   count_array,
    output reg [N*WIDTH-1]   out_array
)
// Included libraries
`include "rtl/common/util/constants.sv".

module constants.sv

// Define constants.sv
`define N_FILES.
`define DUT.sv

// Define the number of files to be tested.sv
`define TESTCASES.sv
// Define the number of test cases.
`define NFILES.sv

// Define the number of tests.sv
`define NFILES.sv

// Define the input and output paths, for example, in_data, 
// - in_data path in the form of a list of input files.
input wire [N*WIDTH-1]:
input wire [N*WIDTH-1]:

- in_data path
input wire [N*WIDTH-1]:

// - in_data path
input wire [N*WIDTH-1]:

// Define the number of files.sv
input wire [N*WIDTH-1]:

// Define the number of test cases.sv
// - test cases path in, for example, test cases path in the form of a list of input files.
input wire [N*WIDTH-1]:

// Define the folder of the test cases.sv
// - in, for example, the folder where the test cases are stored in the folder as follows:
// - in the test cases folder.
`define NFILES.sv

// Define the path of the test cases folder, for example, the path of the test cases.
// - in the test cases folder.
// - Define the path of the test cases.
// - Define the path of the input files and the path of the output files.
// - Define the path of the output files.
// - Define the path of the test cases.

// Define the path of the input files.
// - Define the number of files.

// - Define the path of the test cases.
// - Define the path of the output files.

// - Define the path of the test cases.
// - Define the path of the input files and the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the test cases.
// - Define the path of the test cases.
// - Define the number of files.

// Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the test cases.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the test cases.
// - Define the path of the input files.

// - Define the path of the test cases.
// - Define the path of the output files.

// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the input files.
// - Define the path of the test cases.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the test cases.
// - Define the path of the input files.
// - Define the path of the test cases.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the test cases.
// - Define the path of the output files.
// - Define the path of the test cases.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the test cases.

// - Define the path of the test cases.
// - Define the path of the output files.
// - Define the path of the test cases.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the test cases.
// - Define the path of the input files.

// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the input files.
// - Define the path of the output files.

// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.

// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.

// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.

// - Define the path of the output files.

// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.

// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.

// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the input files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.

// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// -
    //
    // Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - Define the path of the output files.
// - 1
    //
    // Define the path of the output files.
    // - Define the path of the output files.
// - 1 - 1 ]
// - 1] of the output files.
    // Define the path of the output files.
// - Define the path of the output files.
// - 1]
    // - 1 ] of the output files.
// - 1] output files.
// - Define the path of the output files.
// - 1] of the path of the output files.
    // - 1 ] the output files.
// - 1] output files.
// - 1 ] output files.
// - 1 ] output files.

// - 1] output files.
    // - 1 ] of the output files.
// -  output files.
// - 1] output files.
// - 1] of the output files.
// - 1] of the output files.
// - 1 ] of the output files.
// - 1 of the output files.
    // - 1 ] output files.
// -  output files.
// -  the output files.
// - 1] output files.
// - 1] output files.
    // - 1 ] of the output files.
// - 1 output files.
    // - 1 ] output files.
// - 1 ] the output files.
    // - 1] the output files.
    // -  output files.
    // - 1 ] the output files.
    //
    // - 1 ] the output files.
    // -  output files.
    // - 1 ] output files.
// -  output files.
    // -  the output files.
    // - 1 output files.

// - 1] the path of the output files.
// - 1 of the output files.
    // -  output files.
    // -  the output files.
    //
// - 1] output files.
    // - 1 output files.
    // - 1 of the output files.
    // - 1 of the output files.
// - 1 of the output files.
    //

// -  output files.
    // - 1 of the output files.
    // -  output files.
    // - 1 of the output files.
    // -  the output files.
// -  the output files.
    // -  the output files.
    //
    //
    // -  the output files.
    // -  the output files.
// -  the output files.
    // -  output files.
    //.
    // - 1 of the output files.
// -  output files.
    //
    // -  output files.
    // - 1.
    // -  the output files.