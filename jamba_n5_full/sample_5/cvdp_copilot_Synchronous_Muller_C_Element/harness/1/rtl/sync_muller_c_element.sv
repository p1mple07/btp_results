module sync_muller_c_element #(
    parameter NUM_INPUT = 2,
    parameter PIPE_DEPTH = 1
) (
    input  logic                  clk,
    input  logic                  srst,
    input  logic                  clr,
    input  logic                  clk_en,
    input  logic  [NUM_INPUT-1:0] inp,
    output logic                  out
);

    // Pipeline register
    logic [(PIPE_DEPTH * NUM_INPUT) - 1 : 0] pipe;
    reg [NUM_INPUT-1:0] next_pipe;

    initial begin
        @(posedge clk);
        if (!srst) begin
            // Reset phase
            pipe <= {repeat(PIPE_DEPTH) 0};
            out <= 0;
        end
    end

    always @(posedge clk or negedge srst or negedge clr) begin
        if (srst || clr) begin
            // Reset or clear: clear pipeline and output
            pipe <= {repeat(PIPE_DEPTH) 0};
            out <= 0;
        end else if (clk_en) begin
            // Clock cycle: shift pipeline
            for (int i = 0; i < PIPE_DEPTH; i++) begin
                next_pipe[i] = pipe[i];
                pipe[i] = pipe[i+1];
            end
            pipe[PIPE_DEPTH-1] = inp[(PIPE_DEPTH-1)];
        end
    end

    assign out = (all(pipe)) ? 1 : 0;

endmodule
