<<<<<<< SEARCH
always_comb begin : row
    for(int i = 0; i < 4; i++) begin
        for(int j = 0; j < 4; j++) begin
            assign o_data[NBW_DATA-0:j][NBW_DATA-1*4+i] = current_data_ff[i][j];
        end
    end
endrow
endgenerate
=======
always_comb begin : row
    for(int i = 0; i < 4; i++) begin
        for(int j = 0; j < 4; j++) begin
            assign o_data[NBW_DATA-0:j][NBW_DATA-1*4+i] = current_data_ff[i][j];
        end
    end
endrow
endgenerate
>>>>>>> REPLACE