3'd4: begin // WRAP_AROUND
            for (int row = 0; row < NS_R_OUT; row++) begin
                if(i_image_row_start + col >= NS_ROW) begin
                    image_buffer_ff[NS_ROW - (i_image_row_start + col + 1) % NS_ROW][i_image_col_start + row];
                end else if (i_image_col_start + row >= NS_COLUMN) begin
                    image_buffer_ff[i_image_row_start + col][NS_COLUMN - (i_image_col_start + row + 1) % NS_COLUMN];
                end else begin
                    image_buffer_ff[i_image_row_start + col][i_image_col_start + row];
                end
            end
        end
