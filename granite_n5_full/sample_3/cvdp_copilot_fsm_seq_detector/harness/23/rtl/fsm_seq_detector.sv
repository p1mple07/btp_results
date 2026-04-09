module fsm_seq_detector
(
    input  bit     clk_in,       // Free Running Clock
    input  logic   rst_in,       // Active HIGH reset
    input  logic   seq_in,       // Continuous 1-bit Sequence Input
    output logic   seq_detected  // '0': Not Detected. '1': Detected. Will be HIGH for 1 Clock cycle Only
);

// Define types and constants here

// Define state machine variables and registers here

// Implement the state transition logic here

// Implement the detection of the sequence here

// Implement the assertions for the expected behavior here

endmodule