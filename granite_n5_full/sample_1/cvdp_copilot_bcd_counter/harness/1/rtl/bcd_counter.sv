module bcd_counter(
  input wire clk,
  input wire rst,
  output reg [3:0] ms_hr,
  output reg [3:0] ls_hr,
  output reg [3:0] ms_min,
  output reg [3:0] ls_min,
  output reg [3:0] ms_sec,
  output reg [3:0] ls_sec
);

  always @(posedge clk) begin
    if (rst) begin
      ms_hr <= 4'b000;
      ls_hr <= 4'b000;
      ms_min <= 4'b000;
      ls_min <= 4'b000;
      ms_sec <= 4'b000;
      ls_sec <= 4'b000;
    end else begin
      if (ls_sec == 9) begin
        ls_sec <= 4'b0000;
        ms_sec <= ms_sec + 1;
      end else begin
        ls_sec <= ls_sec + 1;
      end

      if (ms_sec == 6) begin
        ms_sec <= 4'b0000;
        ls_min <= ls_min + 1;
      end else begin
        ms_sec <= ms_sec;
      end

      if (ls_min == 10) begin
        ls_min <= 4'b0000;
        ms_min <= ms_min + 1;
      end else begin
        ls_min <= ls_min;
      end

      if (ms_min == 6) begin
        ms_min <= 4'b0000;
        ls_hr <= ls_hr + 1;
      end else begin
        ms_min <= ms_min;
      end

      if (ls_hr == 10) begin
        ls_hr <= 4'b0000;
        ms_hr <= ms_hr + 1;
      end else begin
        ls_hr <= ls_hr;
      end
    end
  end
endmodule