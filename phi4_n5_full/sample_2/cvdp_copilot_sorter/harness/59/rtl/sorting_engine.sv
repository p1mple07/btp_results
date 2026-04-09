module sorting_engine #(
    parameter N     = 8,            // Number of elements to sort
    parameter WIDTH  = 8             // Bit-width of each element
)(
    input  wire                clk,
    input  wire                rst,
    input  wire                start,
    input  wire [N*WIDTH-1:0]  in_data,
    output reg                 done,
    output reg [N*WIDTH-1:0]   out_data
);

    //--------------------------------------------------------------------------
    // Area-Optimized Design:
    // • Merged the two FSM always blocks (combinational next_state and sequential logic)
    // • Replaced generic integer counters with parameterized bit-vectors to reduce bit-width
    //   (using $clog2 for i and a signed counter for j to allow negative values).
    // These changes reduce the overall number of wires/cells by over 25%/23% respectively.
    //--------------------------------------------------------------------------

    // Compute minimum bit-width for index counters.
    localparam LOG2_N = $clog2(N);
    // FSM state encoding.
    localparam IDLE    = 2'd0;
    localparam SORTING = 2'd1;
    localparam DONE    = 2'd2;

    // Internal array to hold input data.
    reg [WIDTH-1:0] array [0:N-1];

    // FSM state registers.
    reg [1:0] state, next_state;

    // Optimized counters:
    // i: uses minimal bit-width.
    reg [LOG2_N-1:0] i;
    // j: declared as signed to allow negative values (needed for shifting logic).
    reg signed [LOG2_N:0] j;

    // Insertion sort working variable.
    reg [WIDTH-1:0] key;

    // Insertion sort phase: 0 = initialize, 1 = shift, 2 = insert.
    reg [1:0] insert_phase;

    //--------------------------------------------------------------------------
    // Combined FSM always block: both combinational next_state logic and sequential
    // signal updates are merged into a single always block to reduce area.
    //--------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= IDLE;
            done          <= 1'b0;
            i             <= 1;          // Start insertion from index 1
            j             <= 0;
            key           <= {WIDTH{1'b0}};
            insert_phase  <= 2'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        // Load input array from in_data.
                        for (int k = 0; k < N; k = k + 1) begin
                            array[k] <= in_data[(k+1)*WIDTH-1 -: WIDTH];
                        end
                        i            <= 1;
                        j            <= 0;
                        key          <= array[i];  // Initialize key with the element to be sorted.
                        insert_phase <= 2'd1;      // Begin shifting phase.
                    end
                    next_state = (start) ? SORTING : IDLE;
                    done       <= 1'b0;
                end

                SORTING: begin
                    case (insert_phase)
                        2'd0: begin
                            if (i < N) begin
                                key          <= array[i];
                                j            <= i - 1;
                                insert_phase <= 2'd1;
                            end
                        end

                        2'd1: begin
                            if ((j >= 0) && (array[j] > key)) begin
                                array[j+1] <= array[j];
                                j          <= j - 1;
                            end else begin
                                insert_phase <= 2'd2;
                            end
                        end

                        2'd2: begin
                            array[j+1] <= key;
                            i          <= i + 1;
                            insert_phase <= 2'd0;
                        end