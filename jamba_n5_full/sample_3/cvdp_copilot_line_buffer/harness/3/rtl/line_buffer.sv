
always_comb begin : window_assignment
    case(i_mode)
        3'd0: begin // NO_BOUND_PROCESS
            for (int row = 0; row < NS_R_OUT; row++) begin
                for (int col = 0; col < NS_C_OUT; col++) begin
                    if(i_image_row_start + col >= NS_ROW) begin
                        window[row][col] = 0;
                    end else if (i_image_col_start + row >= NS_COLUMN) begin
                        window[row][col] = 0;
                    end else begin
                        window[row][col] = image_buffer_ff[i_image_row_start + col][i_image_col_start + row];
                    end
                end
            end
        end
        3'd1: begin // PAD_CONSTANT
            for (int row = 0; row < NS_R_OUT; row++) begin
                for (int col = 0; col < NS_C_OUT; col++) begin
                    if(i_image_row_start + col >= NS_ROW) begin
                        window[row][col] = CONSTANT;
                    end else if (i_image_col_start + row >= NS_COLUMN) begin
                        window[row][col] = CONSTANT;
                    end else begin
                        window[row][col] = image_buffer_ff[i_image_row_start + col][i_image_col_start + row];
                    end
                end
            end
        end
        3'd2: begin // EXTEND_NEAR
            for (int row = 0; row < NS_R_OUT; row++) begin
                for (int col = 0; col < NS_C_OUT; col++) begin
                    if(i_image_row_start + col >= NS_ROW) begin
                        window[row][col] = image_buffer_ff[NS_ROW-1][i_image_col_start + row];
                    end else if (i_image_col_start + row >= NS_COLUMN) begin
                        window[row][col] = image_buffer_ff[i_image_row_start + col][NS_COLUMN-1];
                    end else begin
                        window[row][col] = image_buffer_ff[i_image_row_start + col][i_image_col_start + row];
                    end
                end
            end
        end
        3'd3: begin // MIRROR_BOUND
            for (int row = 0; row < NS_R_OUT; row++) begin
                for (int col = 0; col < NS_C_OUT; col++) begin
                    if(i_image_row_start + col >= NS_ROW) begin
                        window[row][col] = image_buffer_ff[2*NS_ROW-1-(i_image_row_start + col)][i_image_col_start + row];
                    end else if (i_image_col_start + row >= NS_COLUMN) begin
                        window[row][col] = image_buffer_ff[i_image_row_start + col][NS_COLUMN-1-(i_image_col_start + row)];
                    end else begin
                        window[row][col] = image_buffer_ff[i_image_row_start + col][i_image_col_start + row];
                    end
                end
            end
        end
        3'd4: begin // WRAP_AROUND
            for (int row = 0; row < NS_R_OUT; row++) begin
                for (int col = 0; col < NS_C_OUT; col++) begin
                    if(i_image_row_start + col >= NS_ROW) begin
                        window[row][col] = image_buffer_ff[(i_image_row_start + col)-NS_ROW][i_image_col_start + row];
                    end else if (i_image_col_start + row >= NS_COLUMN) begin
                        window[row][col] = image_buffer_ff[i_image_row_start + col][(i_image_col_start + row)-NS_COLUMN];
                    end else begin
                        window[row][col] = image_buffer_ff[i_image_row_start + col][i_image_col_start + row];
                    end
                end
            end
        end
        default: begin
            for (int row = 0; row < NS_R_OUT; row++) begin
                for (int col = 0; col < NS_C_OUT; col++) begin
                    window[row][col] = 0;
                end
            end
        end
    endcase
end
