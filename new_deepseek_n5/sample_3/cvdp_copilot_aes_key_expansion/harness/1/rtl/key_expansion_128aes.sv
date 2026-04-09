module key_expansion_128aes #(
    parameter NBW_KEY = 'd128,
    parameter NBW_OUT = 'd1408
) (
    input  logic               clk,
    input  logic               rst_async_n,
    input  logic [NBW_KEY-1:0] i_key,
    output logic [NBW_OUT-1:0] o_expanded_key
);

localparam NBW_BYTE = 'd8;
localparam STEPS = 'd10;
localparam NBW_WORD = 'd32;

// Auxiliary wires
logic [NBW_WORD-1:0] RconXor;
logic [NBW_WORD-1:0] step_key;

// Internal wires
logic [NBW_WORD-1:0] expanded_key_ff;

// Always comb
always_comb begin : resetoko
    if ($rst_async_n) begin
        expanded_key_ff <= {NBW_OUT{1'b0}};
        o_done <= 11'h00;
    end else begin
        expanded_key_ff <= expanded_key_nx;
        o_done <= 11'h00;
    end
end

assign o_done = 11'h00;

always_comb begin
    // Generate all round keys in one go
    expanded_key_nx = { 
        // Round key 0
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        // Round key 1
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        // Round key 2
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        // Round key 3
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        // Round key 4
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        // Round key 5
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        // Round key 6
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        // Round key 7
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        // Round key 8
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        // Round key 9
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        // Round key 10
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0], 
        expanded_key_ff[31:0]
    };
end

endmodule