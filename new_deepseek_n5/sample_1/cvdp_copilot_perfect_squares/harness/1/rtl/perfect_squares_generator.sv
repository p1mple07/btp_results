import struct

class SystemVerilog:
    def __init__(self):
        self._clk = 0
        self._reset = 0
        self._squares = [31'h800000]  # Initialize with the first square number (1)
    
    def update(self):
        if self._reset:
            self._squares = [31'h800000]  # Reset to 1
            self._clk = 1
            return
        n = self._clk
        next_n = (n ** 2)  # Calculate the next square number
        if next_n > 31'h3141593247:  # Check overflow
            self._squares = [31'h3141593247]  # Saturate at 32-bit max
        else:
            self._squares.append(next_n)
        self._clk += 1  # Increment the clock edge
        
    def get(self):
        return self._squares