module FIFO_RTL #(
    parameter DATA_WIDTH = 8,
    parameter FILO_DEPTH = 16
)(
    input logic clk,
    input logic rst,
    input logic push,
    input logic pop,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic full,
    output logic empty
);
    
    localparam TOP_ADDR = $clog2(FILO_DEPTH)-1;
    logic [TOP_ADDR:0] top;
    logic [$clog2(DATA_WIDTH)-1:0] data_addr;
    
    always @(posedge clk) begin
        if (rst) begin
            top <= 0;
            full <= 0;
            empty <= 1;
        end else begin
            if (push &&!full) begin
                data_addr <= {top, data_addr[TOP_ADDR]};
                if (pop &&!empty) begin
                    data_out <= data_in;
                end
            end else if (!push && pop) begin
                data_out <= #1 data_in;
            end
        end
    end
endmodule