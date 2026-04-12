module cvdp_leading_zero_cnt #(
    parameter DATA_WIDTH = 32, // Multiple of 4  
    parameter REVERSE = 0 // 0 : leading zero, 1 : trailing zero,
)(
    input logic [DATA_WIDTH -1:0] data,
    output logic [$clog2(DATA_WIDTH)-1:0] leading_zeros
);
    localparam NIBBLES_NUM = DATA_WIDTH/4 ; 
    reg [NIBBLES_NUM-1 :0] all_zeros_flag ;
    reg [1:0]  zeros_cnt_per_nibble [NIBBLES_NUM-1 :0]  ;

    genvar i;
    // Assign data/nibble 
    reg [3:0]  data_per_nibble [NIBBLES_NUM-1 :0]  ;
    generate
        for (i=0; i < NIBBLES_NUM ; i++) begin
            always @* begin
                data_per_nibble[i] = data[(i*4)+3: (i*4)] ;
            end
        end
    endgenerate
   
    generate
        for (i=0; i < NIBBLES_NUM ; i++) begin
            if (REVERSE) begin
                always @* begin
                        zeros_cnt_per_nibble[i] [1] = ~(data_per_nibble[i][1] | data_per_nibble[i][0]); 
                        zeros_cnt_per_nibble[i] [0] = (~data_per_nibble[i][0]) &
                                                      ((~data_per_nibble[i][2]) | data_per_nibble[i][1]);
                        all_zeros_flag[i] = (data_per_nibble[i] == 4'b0000);
                end
            end else begin
                always @* begin
                    zeros_cnt_per_nibble[NIBBLES_NUM-1-i][1] = ~(data_per_nibble[i][3] | data_per_nibble[i][2]); 
                    zeros_cnt_per_nibble[NIBBLES_NUM-1-i][0] = (~data_per_nibble[i][3]) &
                                     ((~data_per_nibble[i][1]) | data_per_nibble[i][2]);
                    
                    all_zeros_flag[NIBBLES_NUM-1-i] = (data_per_nibble[i] == 4'b0000);
                end
            end
        end
    endgenerate

    
    
    reg [$clog2(NIBBLES_NUM)-1:0] index ; 
    reg [1:0]    choosen_nibbles_zeros_count ;
    reg [ $clog2(NIBBLES_NUM*4)-1:0] zeros_count_result ;
    wire [NIBBLES_NUM-1:0]         all_zeros_flag_decoded;
    
    assign all_zeros_flag_decoded[0] = all_zeros_flag[0] ;
    genvar j;
        generate
            for (j=1; j < NIBBLES_NUM; j++) begin
                assign all_zeros_flag_decoded[j] = all_zeros_flag_decoded[j-1] & all_zeros_flag[j];
            end
        endgenerate

    always@ * begin
        index = 0 ;
        for ( int i=0 ; i< NIBBLES_NUM ; i++) begin
            index = index + all_zeros_flag_decoded[i] ;
        end
    end
    
    always@* begin
        choosen_nibbles_zeros_count = zeros_cnt_per_nibble[index]  ;  
        zeros_count_result = choosen_nibbles_zeros_count + (index <<2) ; 
    end
    
    assign leading_zeros = zeros_count_result ;

endmodule