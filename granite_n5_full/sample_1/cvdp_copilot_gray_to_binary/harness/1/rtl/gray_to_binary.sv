def gray_to_binary(gray_code):
    """
    Convert a binary-reflected Gray code input to its equivalent binary output.
    
    Args:
        gray_code (int): A binary-reflected Gray code input.
        
    Returns:
        int: The equivalent binary output.
    """
    binary_output = 0
    for i in range(len(bin(gray_code)[2:])):
        bit = gray_code & (1 << i)
        if bit > 0:
            binary_output += 1 << (len(bin(gray_code)[2:]) - i - 1)
    return binary_output