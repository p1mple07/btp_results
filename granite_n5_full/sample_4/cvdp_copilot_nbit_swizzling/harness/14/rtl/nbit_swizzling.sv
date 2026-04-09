module nbit_swizzling #(parameter DATA_WIDTH = 16)(
    input [DATA_WIDTH-1:0] data_in,                                         // Input data of size DATA_WIDTH 
    input [1:0] sel,                	                                    // 2-bit selection signal 
    output reg [DATA_WIDTH+1:0] data_out                                    // Output data of size DATA_WIDTH 
);

reg [DATA_WIDTH-1:0] data_with_parity;
wire [DATA_WIDTH:0] reduced_data;
wire parity_bit;

assign data_with_parity = {data_in, parity_bit};

always @(posedge clk or posedge rstn) begin
    if(rstn == 0) begin
        reduced_data <= 0;
        parity_bit <= 0;
    end else begin
        reduced_data <= ~({1'b0, data_in}) & data_in;
        parity_bit <= ~(reduced_data >> DATA_WIDTH);
    end
end

always @(*) begin
    case(sel)
        2'b00: begin
            data_out = data_in;
        end
        2'b01: begin
            data_out = {data_in[DATA_WIDTH-1:0], parity_bit};
        end
        2'b10: begin
            data_out = {{DATA_WIDTH-1:DATA_WIDTH/2}, data_in[DATA_WIDTH/2-1:0], parity_bit};
        end
        2'b11: begin
            data_out = {{DATA_WIDTH-2:DATA_WIDTH/4}, data_in[DATA_WIDTH/4-1:0], parity_bit};
        end
        default: begin
            data_out = data_with_parity;
        end
    endcase
end

endmodule