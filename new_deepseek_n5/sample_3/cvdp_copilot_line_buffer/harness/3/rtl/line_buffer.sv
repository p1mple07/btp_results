// generate
    for(genvar row = 0; row < NS_R_OUT; row++) begin : out_row
        for(genvar col = 0; col < NS_C_OUT; col++) begin : out_col
            always_comb begin
                if(i_update_window) begin
                    o_image_window[(row*NS_C_OUT+col+1)*NBW_DATA-1-:NBW_DATA] = window[row][col];
                end else begin
                    o_image_window[(row*NS_C_OUT+col+1)*NBW_DATA-1-:NBW_DATA] = image_window_ff[(row*NS_C_OUT+col+1)*NBW_DATA-1-:NBW_DATA];
                end
            end
        end
    end
endgenerate