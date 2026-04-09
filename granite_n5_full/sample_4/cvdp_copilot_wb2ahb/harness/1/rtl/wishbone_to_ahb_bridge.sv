module wishbone_to_ahb_bridge (
    // Wishbone Ports
    input  logic clk_i,              // Clock signal for Wishbone operations
    input  logic rst_i,             // Active-low reset signal
    input  logic cyc_i,             // Valid Wishbone transaction cycle
    input  logic stb_i,             // Strobe signal for valid data on the Wishbone interface
    input  logic [3:0] sel_i,      // Byte enables to select which bytes are active
    input  logic we_i,              // Write enable signal
    input  logic [31:0] addr_i,    // Address for the Wishbone transaction
    input  logic [31:0] data_i,    // Write data from the Wishbone master
    output logic [31:0] data_o,    // Read data back to the Wishbone master
    output logic ack_o,             // Acknowledge signal for Wishbone operations
    
    // AHB Ports
    input  logic hclk,              // Clock signal for AHB operations
    input  logic hreset_n,         // Active-low reset signal for the AHB interface
    output logic [31:0] hrdata,  // Read data from the AHB slave
    output logic [1:0] hresp,     // AHB response signal
    input  logic hready             // Indicates when the AHB slave is ready
);

  // Your implementation here

endmodule