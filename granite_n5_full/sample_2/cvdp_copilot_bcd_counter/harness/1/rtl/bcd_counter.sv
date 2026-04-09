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

  reg [7:0] sec_count;
  reg [6:0] min_count;
  reg [5:0] hr_count;

  always @(posedge clk) begin
    if (rst) begin
      sec_count <= 8'h00;
      min_count <= 7'h00;
      hr_count <= 6'h00;
    end else begin
      if (sec_count == 8'd59) begin
        sec_count <= 8'h00;
        if (min_count == 7'd59) begin
          min_count <= 7'h00;
          if (hr_count == 6'd23) begin
            hr_count <= 6'h00;
          end else begin
            hr_count <= hr_count + 1;
          end
        end else begin
          min_count <= min_count + 1;
        end
      end else begin
        sec_count <= sec_count + 1;
      end
    end
  end

  assign ms_sec = sec_count[7:4];
  assign ls_sec = sec_count[3:0];
  assign ms_min = min_count[6:4];
  assign ls_min = min_count[3:0];
  assign ms_hr = hr_count[5:4];
  assign ls_hr = hr_count[3:0];

endmodule