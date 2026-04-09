
dot_product_valid_out <= 0;
dot_length_reg <= dot_length_in;
if (start_in) begin
    state <= COMPUTE;
    acc <= 0;
    cnt <= 0;
end
