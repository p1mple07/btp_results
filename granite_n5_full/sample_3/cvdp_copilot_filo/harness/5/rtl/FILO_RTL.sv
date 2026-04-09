module FILO_RTL #(parameter DATA_WIDTH = 8,
                    parameter FIFO_DEPTH = 16)(
    // Inputs
    input clk,
    input rst,
    input push,
    input pop,
    input [DATA_WIDTH-1:0] data_in,
    
    // Outputs
    output logic [DATA_WIDTH-1:0] data_out,
    output logic full,
    output logic empty);
    
    // Internal signals
    reg [DATA_WIDTH-1:0] mem[FIFO_DEPTH];
    reg [7:0] top;
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            top <= 0;
            full <= 0;
            empty <= 1;
        end else begin
            if(push &&!full) begin
                mem[top] <= data_in;
                top <= top + 1;
                full <= (top == FIFO_DEPTH - 1)? 1 : 0;
                empty <= (top == 0)? 1 : 0;
            end
            
            if(pop &&!empty) begin
                data_out <= mem[top];
                top <= top - 1;
                empty <= (top == 0)? 1 : 0;
            end
        end
    end
endmodule