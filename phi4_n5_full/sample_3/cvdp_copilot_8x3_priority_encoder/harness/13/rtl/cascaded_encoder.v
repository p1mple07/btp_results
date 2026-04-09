module
// This module is parameterized with an input width N and an output width M = log2(N)
// It outputs the index of the first active input (MSB has highest priority)
// If no inputs are active, it defaults to 0.
////////////////////////////////////////////////////////////////////////////////
module priority_encoder #(parameter N = 8, parameter M = $clog2(N)) (
    input  [N-1:0] input_signal,
    output reg [M-1:0] out
);
    integer i;
    always @(*) begin
        out = 0;
        // Iterate from MSB to LSB to find the first active bit.
        for(i = N-1; i >= 0; i = i - 1) begin
            if (input_signal[i] && out == 0)
                out = i;
        end
    end
endmodule

////////////////////////////////////////////////////////////////////////////////
// New cascaded_encoder module
// This module handles a large input_signal by dividing it into two halves:
// - Upper half: Most significant half
// - Lower half: Least significant half
// Each half is processed by an instance of priority_encoder.
// The final output 'out' represents the index (in the full input width) of the
// highest-priority active input. Additionally, the outputs 'out_upper_half' and
// 'out_lower_half' provide the index within each half for debug purposes.
// If no inputs are active in either half, the output defaults to 0.
////////////////////////////////////////////////////////////////////////////////
module cascaded_encoder #(parameter N = 8, parameter M = $clog2(N)) (
    input  [N-1:0] input_signal,
    output [M-1:0] out,
    output [M-2:0] out_upper_half,
    output [M-2:0] out_lower_half
);
    // Define the size of each half (assumes N is even)
    localparam half_size = N/2;
    
    // Wires to capture the priority indices from each half.
    wire [M-2:0] upper_priority;
    wire [M-2:0] lower_priority;
    
    // Instance for the upper half: bits from N-1 downto half_size
    priority_encoder #(.N(half_size), .M($clog2(half_size))) upper_encoder (
        .input_signal(input_signal[N-1:half_size]),
        .out(upper_priority)
    );
    
    // Instance for the lower half: bits from half_size-1 downto 0
    priority_encoder #(.N(half_size), .M($clog2(half_size))) lower_encoder (
        .input_signal(input_signal[half_size-1:0]),
        .out(lower_priority)
    );
    
    // Final output: if an active bit is found in the upper half, use that index;
    // otherwise, add half_size to the lower half's index.
    always @(*) begin
        if (upper_priority != 0)
            out = upper_priority;
        else
            out = lower_priority + half_size;
    end
endmodule