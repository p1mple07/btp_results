Module declaration
module cipher (
    input wire [31:0] data_in,
    input wire [15:0] key,
    input wire clk,
    input wire rst_n,
    output wire [31:0] data_out,
    output wire done
);

// State declarations
enum state_t: 3 bit [
    IDLE = 0,
    ROUND = 1,
    FINISH = 2
];
reg state = IDLE;

// Key schedule and subkeys
reg [15:0] current_key = key;
reg [15:0] subkeys[8];

initial begin
    // Initialize key for first round
    subkeys[0] = current_key;
    $continue;
end

always @* begin
    // Generate subkeys for each round
    integer i;
    for (i=0; i<8; i=i+1) begin
        current_key = (current_key << 3) | i;
        subkeys[i+1] = current_key;
    end
end

// Feistel function f_function
always @* begin
    // Split data into left and right halves
    reg [15:0] left = data_in[15:0];
    reg [15:0] right = data_in[31:16];

    // Apply f_function
    reg [15:0] transformed_right;
    
    transformed_right = left ^ (right >> 4);
    transformed_right ^= (transformed_right << 5) | (transformed_right >> 2);
    transformed_right ^= subkeys[state + 1];

    // Combine new right and left
    right = transformed_right ^ left;
    left = right;
end

// Main execution path
always @posedge clk begin
    // Check for assertions
    if (rst_n) begin
        // Reset all registers
        state = IDLE;
        left = 0;
        right = 0;
        $finish;
        $continue;
    end

    if (!rst_n && !state) begin
        // Start encryption
        state = ROUND;
        $finish;
    end

    // Run Feistel rounds
    for (int i=0; i<8; i=i+1) begin
        if (state == ROUND) begin
            // Perform f_function
            always @* begin
                reg [15:0] temp_left = left;
                reg [15:0] temp_right = right;
                
                temp_right = (temp_right ^ (subkeys[i] >> 4)) 
                    ^ ((temp_right << 5) | (temp_right >> 2)) 
                    ^ subkeys[i];
                
                right = temp_right ^ temp_left;
                left = right;
            end
        end
    end

    // Swap halves and finalize
    if (state == ROUND) begin
        data_out = (left << 16) | right;
        state = FINISH;
        done = 1;
    end
end

// Finalize state transition
always @posedge clk begin
    if (!rst_n && state == FINISH) begin
        state = IDLE;
        done = 0;
    end
end

// Signal assignment for finish
always @* begin
    if (state == FINISH) {
        done = 1;
    }
end

// End module definition
endmodule