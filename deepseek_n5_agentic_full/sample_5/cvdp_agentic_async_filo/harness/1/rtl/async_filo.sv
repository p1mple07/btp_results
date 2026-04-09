Module Implementation

module async_filo(
    parameter DATA_WIDTH,
    parameter DEPTH,
    input w_clk,
    input w_rst,
    input push,
    input r_clk,
    input r_rst,
    input pop,
    input [DATA_WIDTH-1:0] w_data,
    output [DATA_WIDTH-1:0] r_data,
    output r_empty,
    output w_full
);

    // Internal State Variables
    integer w_ptr, r_ptr;
    integer w_count_bin, r_count_bin;
    reg [DEPTH-1:0] mem;
    reg [DEPTH-1:0] pushed_data;
    integer counter = 0;

    // Helper Functions
    function bit [DATA_WIDTH-1:0] bin2gray(bit [DATA_WIDTH-1:0] b);
        return (b ^ (b >> 1));
    endfunction

    function integer gray2bin(bit [DATA_WIDTH-1:0] g);
        return (g ^ (g >> 1)) & ~(1 << DATA_WIDTH);
    endfunction

    // Converters
    function bit [DATA_WIDTH-1:0] bin2gray();
        return bin2gray($0);
    endfunction

    function integer gray2bin();
        return gray2bin($0);
    endfunction

    // Module Implementation
    always @* 
    begin
        // Reset Handling
        if (w_rst) begin
            w_ptr = 0;
            w_count_bin = 0;
            w_full = 0;
            $display("Reset completed for write domain.");
        end
        if (r_rst) begin
            r_ptr = 0;
            r_count_bin = 0;
            r_empty = 1;
            $display("Reset completed for read domain.");
        end
    end

    // Push Operation
    always @posedge w_clk begin
        if (push && !w_full) begin
            w_data = w_data;
            // Update memory location
            mem[w_ptr] = w_data;
            // Increment counter
            w_count_bin = w_count_bin + 1;
            // Update write pointer
            w_ptr = bin2gray(w_count_bin);
            // Check full condition
            w_full = (w_count_bin == DEPTH);
            $display("Push Operation Complete.");
        end else begin
            $display("Operation Abandoned (FILO Full).");
        end
    end

    // Pop Operation
    always @posedge r_clk begin
        if (pop && !r_empty) begin
            r_data = r_data;
            // Output data
            r_data = mem[r_ptr];
            // Remove data from memory
            mem[r_ptr] = 0;
            // Decrement counter
            r_count_bin = r_count_bin - 1;
            // Update read pointer
            r_ptr = gray2bin(r_count_bin);
            // Check empty condition
            r_empty = (r_count_bin == -(1 << (DATA_WIDTH - 1)));
            $display("Pop Operation Complete.");
        end else begin
            $display("Operation Abandoned (FILO Empty).");
        end
    end
endmodule