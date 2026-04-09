assign enc_data_out = {enc_data_out[{2*N-1:N}], enc_data_out[{N-1:0}]};
   assign enc_valid_out = enc_valid_in;

assign enc_data_out = {enc_data_out[{2*N-1:N}], enc_data_out[{N-1:0}]};
   assign enc_valid_out = enc_valid_in;

assign dec_data_out = {dec_data_out[{N-1:0}], dec_data_out[{N-1:0}]};
   assign dec_valid_out = dec_valid_in;

assign dec_data_out = {dec_data_out[{N-1:0}], dec_data_out[{N-1:0}]};
   assign dec_valid_out = dec_valid_in;