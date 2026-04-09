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

    // Internal array (packed array of registers)
    reg [WIDTH-1:0] array [0:N-1];

    // FSM state encoding
    localparam IDLE    = 2'd0;
    localparam SORTING = 2'd1;
    localparam DONE    = 2'd2;

    reg [1:0] state;
    reg [1:0] insert_phase;
    integer   i;
    integer   j;
    reg [WIDTH-1:0] key;
    // Local register for next state computation
    reg [1:0] next_state;

    // Merged FSM always block (combining combinational next_state logic and sequential updates)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            done         <= 0;
            i            <= 0;
            j            <= 0;
            key          <= 0;
            insert_phase <= 0;
            next_state   <= IDLE;
        end else begin
            // Combinational next state logic (using old state value)
            case (state)
                IDLE:    next_state = (start) ? SORTING : IDLE;
                SORTING: next_state = (i == N) ? DONE : SORTING;
                DONE:    next_state = IDLE;
                default: next_state = IDLE;
            endcase

            // Update state register
            state <= next_state;

            // Sequential state actions
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        // Unroll the loop to load the input array.
                        // (Assumes N is constant; for N=8, this unrolling reduces loop control overhead.)
                        array[0]  <= in_data[WIDTH-1:0];
                        array[1]  <= in_data[2*WIDTH-1:WIDTH];
                        array[2]  <= in_data[3*WIDTH-1:2*WIDTH];
                        array[3]  <= in_data[4*WIDTH-1:3*WIDTH];
                        array[4]  <= in_data[5*WIDTH-1:4*WIDTH];
                        array[5]  <= in_data[6*WIDTH-1:5*WIDTH];
                        array[6]  <= in_data[7*WIDTH-1:6*WIDTH];
                        array[7]  <= in_data[8*WIDTH-1:7*WIDTH];
                        i         <= 1;    // Start insertion sort from index 1
                        j         <= 0;
                        key       <= 0;
                        insert_phase <= 0;
                    end
                end

                SORTING: begin
                    // Insertion sort phases
                    case (insert_phase)
                        0: begin
                            if (i < N) begin
                                key       <= array[i];
                                j         <= i - 1;
                                insert_phase <= 1;
                            end
                        end

                        1: begin
                            if (j >= 0 && array[j] > key) begin
                                array[j+1] <= array[j];
                                j         <= j - 1;
                            end else begin
                                insert_phase <= 2;
                            end
                        end

                        2: begin
                            array[j+1] <= key;
                            i         <= i + 1;
                            insert_phase <= 0;
                        end

                        default: insert_phase <= 0;
                    endcase
                end

                DONE: begin
                    done <= 1;
                    // Unroll the loop to assign sorted data to output.
                    out_data[WIDTH-1:0]     <= array[0];
                    out_data[2*WIDTH-1:WIDTH]     <= array[1];
                    out_data[3*WIDTH-1:2*WIDTH]   <= array[2];
                    out_data[4*WIDTH-1:3*WIDTH]   <= array[3];
                    out_data[5*WIDTH-1:4*WIDTH]   <= array[4];
                    out_data[6*WIDTH-1:5*WIDTH]   <= array[5];
                    out_data[7*WIDTH-1:6*WIDTH]   <= array[6];
                    out_data[8*WIDTH-1:7*WIDTH]   <= array[7];
                end

                default: ;
            endcase
        end
    end

endmodule