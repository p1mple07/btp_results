def rle_encode(data_in, max_len):
    # Initialize variables
    run_value = 0
    run_length = 0
    data_out = 0
    valid = 0
    prev_data_in = 0
    
    # Generate RLE code based on data_in
    for i in range(len(data_in)):
        if data_in[i] == prev_data_in:
            run_length += 1
            if run_length >= max_len:
                run_value += 1
                run_length = 0
                data_out = prev_data_in
        else:
            if run_length > 0:
                run_value += 1
                run_length = 0
            prev_data_in = data_in[i]
        
        valid = 1 if run_length >= max_len else 0
        
    return (run_value, data_out, valid)