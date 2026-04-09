module queue #(
  parameter DEPTH = 8,
  parameter DBITS = 16,
  parameter ALMOST_EMPTY_THRESHOLD = 5,
  parameter ALMOST_FULL_THRESHOLD = 10
) (
  input wire clk_i,
  input wire rst_ni,
  input wire clr_i,
  input wire ena_i,
  input wire we_i,
  input wire d_i,
  output reg q_o,
  output reg empty_o,
  output reg full_o,
  output reg almost_empty_o,
  output reg almost_full_o
);

localparam WIDTH = DBITS;
localparam TOTAL_ENTRIES = DEPTH;

reg [TOTAL_ENTRIES-1:0] queue_data;
reg [1:0] queue_wadr;

always_ff @(posedge clk_i) begin
  if (~rst_ni) begin
    queue_data <= {};
    queue_wadr <= 0;
    q_o <= 0;
    empty_o <= 1;
    full_o <= 0;
    almost_empty_o <= 0;
    almost_full_o <= 0;
  end else if (!clr_i) begin
    queue_data <= {};
    queue_wadr <= 0;
    q_o <= 0;
    empty_o <= 1;
    full_o <= 0;
    almost_empty_o <= 0;
    almost_full_o <= 0;
  end else
    if (we_i && re_i) begin
      if (queue_wadr == 0) begin
        queue_data[0] <= d_i;
      end else if (queue_wadr == TOTAL_ENTRIES-1) begin
        queue_data[TOTAL_ENTRIES-1] <= d_i;
      end else begin
        queue_data[queue_wadr+1] <= d_i;
      end
      queue_wadr++;
    end else if (we_i) begin
      queue_data[queue_wadr] <= d_i;
      queue_wadr++;
    end else if (re_i) begin
      if (queue_wadr > 0) queue_data[0] <= queue_data[1];
      else if (queue_wadr < TOTAL_ENTRIES-1) queue_data[queue_wadr] <= queue_data[queue_wadr+1];
      q_o <= queue_data[0];
      empty_o <= (queue_wadr == 0);
      full_o <= (queue_wadr == TOTAL_ENTRIES-1);
      almost_empty_o <= (queue_wadr == ALMOST_EMPTY_THRESHOLD);
      almost_full_o <= (queue_wadr == ALMOST_FULL_THRESHOLD);
    end
  end
end

always @(*) begin
  q_o = queue_data[0];
  empty_o <= (queue_wadr == 0);
  full_o <= (queue_wadr == TOTAL_ENTRIES-1);
  almost_empty_o <= (queue_wadr == ALMOST_EMPTY_THRESHOLD);
  almost_full_o <= (queue_wadr == ALMOST_FULL_THRESHOLD);
end

endmodule
