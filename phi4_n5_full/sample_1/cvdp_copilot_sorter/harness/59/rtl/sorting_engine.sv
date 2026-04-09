module sorting_engine #(
    parameter N      = 8,         // Number of elements to sort
    parameter WIDTH   = 8          // Bit-width of each element
)(
    input  wire                clk,
    input  wire                rst,
    input  wire                start,
    input  wire [N*WIDTH-1:0]  in_data,
    output reg                 done,
    output reg [N*WIDTH-1:0]   out_data
);

    // Internal array
    reg [WIDTH-1:0] array [0:N-1];

    // Combined FSM state (merging state and insertion-phase into one register)
    typedef enum logic [2:0] {
        IDLE           = 3'd0,
        INSERT_SETUP   = 3'd1,
        INSERT_SHIFT   = 3'd2,
        INSERT_INSERT  = 3'd3,
        DONE           = 3'd4
    } state_t;
    state_t state, next_state;

    // Insertion sort variables
    integer i;
    integer j;
    reg [WIDTH-1:0] key;

    // Combinational Next State Logic (using blocking assignments for area efficiency)
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:   next_state = start ? INSERT_SETUP : IDLE;
            INSERT_SETUP: next_state = (i < N) ? INSERT_SHIFT : DONE;
            INSERT_SHIFT: next_state = ((j >= 0) && (array[j] > key)) ? INSERT_SHIFT : INSERT_INSERT;
            INSERT_INSERT: next_state = INSERT_SETUP;
            DONE:    next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Sequential Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            done    <= 1'b0;
            i       <= 0;
            j       <= 0;
            key     <= '0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        // Load array from in_data
                        for (int k = 0; k < N; k = k + 1) begin
                            array[k] <= in_data[(k+1)*WIDTH-1 -: WIDTH];
                        end
                        i <= 1;  // Start insertion sort from index 1
                        j <= 0;
                        key <= 0;
                    end
                end
                INSERT_SETUP: begin
                    // Phase: Setup for inserting array[i]
                    key <= array[i];
                    j <= i - 1;
                end
                INSERT_SHIFT: begin
                    // Phase: Shift elements to the right until the correct spot is found
                    if ((j >= 0) && (array[j] > key)) begin
                        array[j+1] <= array[j];
                        j <= j - 1;
                    end
                end
                INSERT_INSERT: begin
                    // Phase: Insert the key at array[j+1] and advance to next element
                    array[j+1] <= key;
                    i <= i + 1;
                end
                DONE: begin
                    // Sorting complete: output the sorted result
                    done <= 1'b1;
                    for (int m = 0; m < N; m = m + 1) begin
                        out_data[(m+1)*WIDTH-1 -: WIDTH] <= array[m];
                    end
                end
                default: ;
            endcase
        end
    end

endmodule