// Module declaration with parameters
module async_filo (
    parameter integer DATA_WIDTH = 8,
    parameter integer DEPTH = 8
);

// Internal variables and structures
reg [DATA_WIDTH-1:0] w_data;
wire [DATA_WIDTH-1:0] r_data;
input r_empty;
output w_full;

// State variables and control signals
integer w_ptr, r_ptr;
integer w_count_bin, r_count_bin;
integer q1, q2;
always_comb function [
    integer w_count_bin;
    integer r_count_bin;
]
    out integer bin2gray() const {
        return (w_count_bin ^ (w_count_bin >> 1)) & ((1 << DATA_WIDTH) - 1);
    }
    
    integer gray2bin(const int gray_code) {
        int b = gray_code;
        while (b != 0 && b != b >> 1) {
            b = b ^ (b >> 1);
        }
        return b;
    }

// Instantiate the DUT
async_filo_inst
    (
        .w_clk(w_clk),
        .w_rst(w_rst),
        .push(push),
        .r_rst(r_rst),
        .r_clk(r_clk),
        .pop(pop),
        .w_data(w_data),
        .r_data(r_data),
        .r_empty(r_empty),
        .w_full(w_full)
    );

// Always blocks
always @(posedge w_clk or posedge r_clk) begin
    if ($event w_rst) begin
        w_ptr = 0;
        r_ptr = 0;
        w_count_bin = 0;
        r_count_bin = 0;
        q1 = 0;
        q2 = 0;
        empty = 1;
        full = 0;
    end
    if ($event r_rst) begin
        w_ptr = 0;
        r_ptr = 0;
        w_count_bin = 0;
        r_count_bin = 0;
        q1 = 0;
        q2 = 0;
        empty = 1;
        full = 0;
    end
end

// Tasks for testing functionality
task simulate_behavior() begin
    // Reset behavior
    $display("Applying Reset...");
    #20;
    w_rst = 0;
    r_rst = 0;
    $display("Reset Complete");
    $display("Depth = 8");
    $display("Empty Status: %0d | Full Status: %0d", empty, full);

    // Perform 3 Push Operations
    push_data($urandom_range(0, (1 << DATA_WIDTH) - 1));
    push_data($urandom_range(0, (1 << DATA_WIDTH) - 1));
    push_data($urandom_range(0, (1 << DATA_WIDTH) - 1));

    $display("Performing 3 Pop Operations...");
    pop_data();
    pop_data();
    pop_data();

    $display("Test Completed.");
    #100;
    $finish;
end

// Task definitions
task push_data(input [DATA_WIDTH-1:0] data_in);
begin
    if (!full) begin
        w_data = data_in;
        pushed_data[q1] = data_in;
        w_ptr = gray2bin(w_ptr) ^ 1;
        q1 = q1 + 1;
        full = (q1 > DEPTH);
    end
end

task pop_data;
begin
    if (!empty) begin
        r_data = pushed_data[q2];
        popped_data[q2] = r_data;
        r_ptr = gray2bin(r_ptr) ^ 1;
        q2 = q2 - 1;
    end
end

// Signal declarations
reg integer w_count_bin, r_count_bin;
reg integer q1, q2;
reg [DEPTH-1:0] pushed_data, popped_data;