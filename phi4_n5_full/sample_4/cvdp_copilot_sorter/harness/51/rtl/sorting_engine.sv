module sorting_engine #(
    parameter N = 8,             // Number of elements to sort
    parameter WIDTH = 8          // Bit-width of each element
)(
    input  wire                clk,
    input  wire                rst,
    input  wire                start,
    input  wire [N*WIDTH-1:0]  in_data,
    output reg                 done,
    output reg [N*WIDTH-1:0]   out_data
);

    // Internal registers to hold the array
    reg [WIDTH-1:0] array [0:N-1];

    // FSM states
    localparam IDLE    = 2'd0;
    localparam SORTING = 2'd1;
    localparam DONE    = 2'd2;

    // FSM state register
    reg [1:0] state;

    // Bubble sort counters
    int i;  // Outer loop index
    int j;  // Inner loop index

    // Single always block combining FSM, data loading, sorting, and output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state  <= IDLE;
            i      <= 0;
            j      <= 0;
            done   <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        // Load the array from in_data
                        for (int k = 0; k < N; k = k + 1) begin
                            array[k] <= in_data[(k+1)*WIDTH-1 -: WIDTH];
                        end
                        state <= SORTING;
                        i     <= 0;
                        j     <= 0;
                    end
                end

                SORTING: begin
                    // Compare adjacent elements and swap if out of order
                    if (array[j] > array[j+1]) begin
                        // Use a temporary register to reduce combinational logic
                        reg [WIDTH-1:0] temp;
                        temp = array[j];
                        array[j]   <= array[j+1];
                        array[j+1] <= temp;
                    end

                    // Update inner loop counter; reset after reaching the end of a pass
                    if (j == N-2) begin
                        j <= 0;
                        i <= i + 1;
                    end else begin
                        j <= j + 1;
                    end

                    // Transition to DONE state after completing all passes
                    if (i == N-1) begin
                        state <= DONE;
                    end else begin
                        state <= SORTING;
                    end
                end

                DONE: begin
                    // Sorting complete; assert done flag and output sorted data
                    done <= 1;
                    for (int m = 0; m < N; m = m + 1) begin
                        out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                    end
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule