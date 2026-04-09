wire parity_bit_even = ^p_data_i;   // XOR => "even"
wire parity_bit_odd  = ~^p_data_i;  // invert XOR => "odd"
