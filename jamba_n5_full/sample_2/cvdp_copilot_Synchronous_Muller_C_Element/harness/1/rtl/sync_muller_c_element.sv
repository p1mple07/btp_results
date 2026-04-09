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

logic [NUM_INPUT-1:0] pipe;
reg last_out;

always @(posedge clk or posedge srst or posedge clr) begin
  if (srst || clr) begin
    pipe <= '{ value: 0 };
    out <= 1'b0;
  end else if (clk_en) begin
    if (!last_out) begin
      pipe[0] <= inp;
    end else begin
      for (int i = 0; i < PIPE_DEPTH; i++) begin
        if (i == 0) begin
          pipe[i] <= pipe[i-1];
        end else begin
          pipe[i] <= pipe[i-1];
        end
      end
    end
  end else begin
    // Retain current state
  end
end

assign out = (pipe[PIPE_DEPTH-1] == 1'b1) ? 1'b1 : 1'b0;

endmodule
