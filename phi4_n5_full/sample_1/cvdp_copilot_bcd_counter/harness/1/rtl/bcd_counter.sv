module bcd_counter (
    input  logic clk,
    input  logic rst,
    output logic [3:0] ms_hr,
    output logic [3:0] ls_hr,
    output logic [3:0] ms_min,
    output logic [3:0] ls_min,
    output logic [3:0] ms_sec,
    output logic [3:0] ls_sec
);

  // On every positive edge of clk, update the counters.
  // When rst is high, reset all counters to 00:00:00.
  always_ff @(posedge clk) begin
    if (rst) begin
      ms_hr  <= 4'd0;
      ls_hr  <= 4'd0;
      ms_min <= 4'd0;
      ls_min <= 4'd0;
      ms_sec <= 4'd0;
      ls_sec <= 4'd0;
    end
    else begin
      // Update seconds
      if (ls_sec == 9) begin
        ls_sec <= 4'd0;
        if (ms_sec == 5) begin
          ms_sec <= 4'd0;
          // Update minutes when seconds complete a full cycle (59)
          if (ls_min == 9) begin
            ls_min <= 4'd0;
            if (ms_min == 5) begin
              ms_min <= 4'd0;
              // Update hours when minutes complete a full cycle (59)
              if (ms_hr == 2 && ls_hr == 3) begin
                // Hour counter is 23; reset entire clock (24-hour wrap-around)
                ms_hr  <= 4'd0;
                ls_hr  <= 4'd0;
                ms_min <= 4'd0;
                ls_min <= 4'd0;
                ms_sec <= 4'd0;
                ls_sec <= 4'd0;
              end
              else begin
                // Increment hour counter
                if (ms_hr == 0) begin
                  if (ls_hr == 9)
                    ls_hr <= 4'd0;
                  else
                    ls_hr <= ls_hr + 1;
                  ms_hr <= ms_hr + 1;
                end
                else if (ms_hr == 1) begin
                  if (ls_hr == 9)
                    ls_hr <= 4'd0;
                  else
                    ls_hr <= ls_hr + 1;
                  ms_hr <= ms_hr + 1;
                end
                else if (ms_hr == 2) begin
                  // For 20-23, ls_hr can only go from 0 to 3.
                  if (ls_hr == 3)
                    ls_hr <= 4'd0;
                  else
                    ls_hr <= ls_hr + 1;
                  ms_hr <= ms_hr + 1;
                end
              end
            end
            else begin
              ms_min <= ms_min + 1;
            end
          end
          else begin
            ls_min <= ls_min + 1;
          end
        end
        else begin
          ms_sec <= ms_sec + 1;
        end
      end
      else begin
        ls_sec <= ls_sec + 1;
      end
    end
  end

endmodule