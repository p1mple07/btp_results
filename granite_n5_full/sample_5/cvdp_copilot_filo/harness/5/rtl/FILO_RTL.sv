module FILO_RTL #(parameter DATA_WIDTH = 8, parameter FILO_DEPTH = 16)(
    input logic clk,
    input logic rst,
    input logic push,
    input logic pop,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic full,
    output logic empty
);

logic [DATA_WIDTH-1:0] mem[FILO_DEPTH-1:0];
logic [DATA_WIDTH-1:0] data_mem;
logic [4:0] top;

assign data_out = data_mem;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        top <= 0;
        full <= 0;
        empty <= 1;
    end else begin
        if(push &&!full) begin
            mem[top] <= data_in;
            top <= top + 1;
            if(top == FILO_DEPTH) top <= 0;
            full <= (top == FIFO_DEPTH-1);
            empty <= 0;
        end
        
        if(pop &&!empty) begin
            data_mem <= mem[top];
            top <= top + 1;
            if(top == FILO_DEPTH-1) top <= 0;
            if(pop &&!empty) empty <= 0;
        end
    end
end

endmodule