module dual_port_memory #(
    parameter int DATA_WIDTH = 32,
    parameter int ECC_WIDTH = 4
) (
    // Port A
    input  logic         rst_n,          // Reset (active low)
    input  logic         wr_a,            // Write enable for A port
    input  logic [DATA_WIDTH-1:0] data_in_a,       // Data input for A port
    output logic [DATA_WIDTH-1:0] data_out_a,     // Data output for A port
    output logic [ECC_WIDTH-1:0] ecc_out_a,    // ECC code output for A port

    // Port B
    input  logic         wr_b,             // Write enable for B port
    input  logic [DATA_WIDTH-1:0] data_in_b,    // Data input for B port
    output logic [DATA_WIDTH-1:0] data_out_b,   // Data output for B port
    output logic [ECC_WIDTH-1:0] ecc_out_b    // ECC code output for B port
) ;

module dual_port_memory_tb;
logic rst_n;  // Reset
logic wr_a;  // Write Enable for A port
logic signed [31:0] data_in_a;  // Data input for A port
logic signed [31:0] data_out_a;  // Data output for A port
logic signed [31:0] data_in_b;  // Data input for B port
logic signed [31:0] data_out_b;  // Data output for B port

//...
//...

endmodule

module rtl/verilog_files.sv
`define DUTs
//...
`define DUTs
//...
//...

endmodule