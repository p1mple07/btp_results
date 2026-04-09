module dual_port_memory #(
    parameter DATA_WIDTH = 4,
    parameter ECC_WIDTH = 3,
    parameter ADDR_WIDTH = 5,
    parameter MEM_DEPTH = 1 << ADDR_WIDTH
) (
    input clk,
    input rst_n,
    input we,
    input [ADDR_WIDTH-1:0] addr_a,
    input [ADDR_WIDTH-1:0] addr_b,
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out,
    output [ECC_WIDTH-1:0] ecc_error
);

reg [DATA_WIDTH-1:0] ram_data [MEM_DEPTH-1:0];

always @* begin
    // Write operation
    assign ram_data[addr_a] = data_in;

    // Write operation
    always @(posedge clk) begin
        // Write operation
        if(we) begin
            // Update RAM
            ram_data[addr_a] <= data_in;
        end else begin
            // Display message for bad inputs
            $display("Bad inputs found. Please check your input and code in the repository");
            $stop();
        end
    end

endmodule