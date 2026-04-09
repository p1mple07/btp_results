module sorting_engine #(
    parameter int N = 8, // number of elements to sort
    parameter int WIDTH = 8 // bit-width of each element
)(
    input logic clk, // main clock input
    input logic rst, // active high, asynchronous reset
    input logic start, // active high, pulse start signal
    input logic [N*WIDTH-1:0] in_data, // input data bus
    output logic done, // active high, pulse signal when sorting is complete
    output logic [N*WIDTH-1:0] out_data // output data bus
);

    localparam int PASS_COUNT = N*(N-1); // number of passes required for bubble sort
    localparam int SORT_TIME = PASS_COUNT+2; // total time taken for sorting

    typedef enum logic {
        IDLE,
        SORTING,
        DONE
    } fsm_state_t;

    fsm_state_t state, next_state;
    logic [N*WIDTH-1:0] sorted_data;
    logic [PASS_COUNT-1:0][N*WIDTH-1:0] comp_data; // compare data for bubble sort

    always_comb begin
        sorted_data = in_data; // initialize sorted data to input data

        case(state)
            IDLE: begin
                if (start)
                    next_state = SORTING;
                else
                    next_state = IDLE;
            end

            SORTING: begin
                for (int i=0; i<PASS_COUNT; i++) begin
                    for (int j=0; j<N-1; j++) begin
                        if (sorted_data[j*WIDTH +: WIDTH] > sorted_data[(j+1)*WIDTH +: WIDTH]) begin
                            comp_data[i][j*WIDTH +: WIDTH] = sorted_data[(j+1)*WIDTH +: WIDTH];
                            comp_data[i][(j+1)*WIDTH +: WIDTH] = sorted_data[j*WIDTH +: WIDTH];
                        end
                        else begin
                            comp_data[i][j*WIDTH +: WIDTH] = sorted_data[j*WIDTH +: WIDTH];
                            comp_data[i][(j+1)*WIDTH +: WIDTH] = sorted_data[(j+1)*WIDTH +: WIDTH];
                        end
                    end

                    sorted_data = comp_data[i]; // update sorted data with current comparison result
                end

                next_state = DONE;
            end

            DONE: begin
                next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
        end
        else begin
            state <= next_state;
            done <= (state == DONE);
        end
    end

    assign out_data = sorted_data; // assign sorted data to output data bus

endmodule