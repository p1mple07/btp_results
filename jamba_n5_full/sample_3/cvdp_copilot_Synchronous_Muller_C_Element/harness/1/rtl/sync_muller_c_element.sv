module sync_muller_c_element #(
    parameter NUM_INPUT = 2,
    parameter PIPE_DEPTH = 1
) (
    input  logic                  clk   ,
    input  logic                  srst  ,
    input  logic                  clr   ,
    input  logic                  clk_en,
    input  logic  [NUM_INPUT-1:0] inp   ,
    output logic                  out    
);

    logic [(PIPE_DEPTH*NUM_INPUT)-1:0] pipe;
    reg [NUM_INPUT:0] stage_ptr;

    initial begin
        stage_ptr = 0;
    end

    always @(posedge clk or posedge clk_en or posedge clr) begin
        if (~srst) begin
            // Reset all to 0
            for (i=0; i < PIPE_DEPTH*NUM_INPUT; i++) pipe[i] <= 1'b0;
            out <= 1'b0;
        end else if (clk_en) begin
            // Propagate through stages
            for (i=1; i < PIPE_DEPTH; i++) begin
                for (j=0; j < NUM_INPUT; j++) pipe[i*(NUM_INPUT+1)+j] = pipe[(i-1)*NUM_INPUT+j];
            end
        end else if (clr) begin
            // Clear
            for (i=0; i < PIPE_DEPTH*NUM_INPUT; i++) pipe[i] <= 1'b0;
            out <= 1'b0;
        end
    end

    assign out = (pipe[PIPE_DEPTH-1] == 1'b1) ? 1'b1 : 1'b0;

endmodule
