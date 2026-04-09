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

    // Use minimal counter width based on N for area reduction.
    localparam COUNTER_WIDTH = $clog2(N);

    // Internal register array to hold the elements.
    reg [WIDTH-1:0] array [0:N-1];

    // FSM states.
    localparam IDLE    = 2'd0;
    localparam SORTING = 2'd1;
    localparam DONE    = 2'd2;

    // State register and reduced-width loop counters.
    reg [1:0] state;
    reg [COUNTER_WIDTH-1:0] i, j;

    // Single always block combining state transitions and updates.
    // Merging logic reduces both sequential registers and combinational wires.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            i     <= 0;
            j     <= 0;
            done  <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        // Load the array from in_data.
                        for (int k = 0; k < N; k = k + 1) begin
                            array[k] <= in_data[(k+1)*WIDTH-1 -: WIDTH];
                        end
                        i <= 0;
                        j <= 0;
                        state <= SORTING;
                    end
                end

                SORTING: begin
                    // Perform a single comparison and swap if needed.
                    // Using blocking assignments inside the always block via a local temporary variable
                    // (supported in many synthesis flows) reduces extra registers and combinational logic.
                    if (array[j] > array[j+1]) begin
                        // Local temporary variable for swapping.
                        reg [WIDTH-1:0] temp;
                        temp = array[j];
                        array[j] = array[j+1];
                        array[j+1] = temp;
                    end

                    // Update inner and outer loop counters.
                    if (j == N-2) begin
                        j <= 0;
                        i <= i + 1;
                        if (i == N-1)
                            state <= DONE;
                        else
                            state <= SORTING;
                    end
                    else begin
                        j <= j + 1;
                        state <= SORTING;
                    end
                end

                DONE: begin
                    done <= 1;
                    // Output the sorted data.
                    for (int m = 0; m < N; m = m + 1) begin
                        out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                    end
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule