module hamming_tx #(
    //Insert code here for parameters
 )(
    input  [DATA_WIDTH-1:0]    data_in,
    output [TOTAL_ENCODED-1:0] data_out
);

  
    genvar i;

            //Insert code here for splitting in to t_hamming_tx instances and constructing final output
    
endmodule



module t_hamming_tx #(
    parameter DATA_WIDTH       = 4,
    parameter PARITY_BIT       = 3,
    parameter ENCODED_DATA     = PARITY_BIT + DATA_WIDTH + 1,
    parameter ENCODED_DATA_BIT = $clog2(Encoded_DATA)
)(
    input  [DATA_WIDTH-1:0]       data_in,
    output  reg[Encoded_Data-1:0] data_out
);

    reg [Parity_Bit-1:0] parity;
    integer i, j, count;
    reg [Encoded_Data_Bit:0] pos;

    always @(*) begin
        data_out = {Encoded_Data{1'b0}};
        parity   = {Parity_Bit{1'b0}};
        count    = 0;

        for (pos = 1; pos < Encoded_Data; pos = pos + 1) begin
            if (count < Data_Width) begin
                if ((pos & (pos - 1))!= 0) begin
                    data_out[pos] = data_in[count];
                    count = count + 1;
                end
            end
        end

        for (j = 0; j < Parity_Bit; j = j + 1) begin
            for (i = 1; i <= Encoded_Data-1; i = i + 1) begin
                if ((i & (1 << j))!= 0) begin
                    parity[j] = parity[j] ^ data_out[i];
                end
            end
        end

        for (j = 0; j < Parity_Bit; j = j + 1) begin
            data_out[(1 << j)] = parity[j];
        end
    end

endmodule