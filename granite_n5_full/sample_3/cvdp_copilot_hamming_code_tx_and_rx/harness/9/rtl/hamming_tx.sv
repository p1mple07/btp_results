def hamming_tx(data_in, DATA_WIDTH, PARITY_BIT):
    assert isinstance(data_in, int) and isinstance(DATA_WIDTH, int) and isinstance(PARITY_BIT, int)
    
    ENCODED_DATA = 2 ** (PARITY_BIT + DATA_WIDTH + 1) - 1
    ENCODED_DATA_BIT = len(bin(Encoded_DATA)) - 2
    data_out = [0] * ENCODED_DATA
    for i in range(DATA_WIDTH):
        data_out[i] = data_in[i]
    
    for i in range(PARITY_BIT):
        data_out[(2**i)] = 0
    
    return data_out