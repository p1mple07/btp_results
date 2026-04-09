module swizzler(#define NUM_LANES 4, #define DATA_WIDTH 8)( 
    parameter integer NUM_LANES = 4, 
    parameter integer DATA_WIDTH = 8, 
    parameter integer REGISTER_OUTPUT = 0, 
    parameter integer ENABLE_PARITY_CHECK = 0
) (
    input wire clock,
    input wire rst_n,
    input wire bypass,
    input wire [NUM_LANES*DATA_WIDTH-1:0] data_in,
    input wire [NUM_LANES:$clog2(NUM_LANES)-1:0] swizzle_map_flat,
    output reg [NUM_LANES*DATA_WIDTH-1:0] data_out,
    output reg parity_error
)

# Include helper functions from swizzler_specification.md

always @ (posedge clock or posedge rst_n) begin
    // Initialize registers on first clock cycle after power-up
    if (rst_n == 0)
        initial_reg;
    // After setup completes, run regular tasks
    else
        main_task;
    end

// Reset and clean-up sequence
reset_sequence:
    $display("Starting SWIZZLER reset sequence...");
    repeat (4 * NUM_LANES) begin
        #include "test_< b:hex >.sv" & 
        $finish
    end;
    $display("SWIZZLER initialization complete.");
    $finish;

// Main task sequence
main_task:
    #start_test_phase;
    while (!done) begin
        #select_phase phase;
        case ($phase)
            // Test case: Bypass mode
            0: test_bypass();
            // Test case: Identity mapping
            1: test_identity();
            // Test case: Reverse mapping
            2: test_reverse();
            // Test case: Custom mapping
            3: test_custom();
            default: $break;
        endcase
        #next_phase;
        wait;
    endwhile;
    $display("All tests completed successfully.");
    $finish;

// Task definitions omitted for brevity

endmodule