module bcd_counter (
  input  logic         clk,
  input  logic         rst,
  output logic [3:0]   ms_hr,
  output logic [3:0]   ls_hr,
  output logic [3:0]   ms_min,
  output logic [3:0]   ls_min,
  output logic [3:0]   ms_sec,
  output logic [3:0]   ls_sec
);

  // Sequential process to update counters on each positive clock edge.
  always_ff @(posedge clk) begin
    if (rst) begin
      ms_sec <= 0;
      ls_sec <= 0;
      ms_min <= 0;
      ls_min <= 0;
      ms_hr  <= 0;
      ls_hr  <= 0;
    end
    else begin
      // Update seconds counter.
      if (ls_sec == 9) begin
        ls_sec <= 0;
        if (ms_sec == 5) begin
          ms_sec <= 0;
          // Seconds have rolled over; update minutes.
          if (ls_min == 9) begin
            ls_min <= 0;
            if (ms_min == 5) begin
              ms_min <= 0;
              // Minutes have rolled over; update hours.
              if (ms_hr == 2 && ls_hr == 3) begin
                // The clock has reached 23:59:59. Reset the entire clock.
                ms_hr   <= 0;
                ls_hr   <= 0;
                ms_sec  <= 0;
                ls_sec  <= 0;
                ms_min  <= 0;
                ls_min  <= 0;
              end
              else if (ls_hr == 9) begin
                // For hours with ms_hr = 0 or 1, roll over the low digit.
                ls_hr <= 0;
                ms_hr <= ms_hr + 1;
              end
              // Otherwise, no hour update is needed.
            end
            else begin
              ms_min <= ms_min + 1;
            end
          end
          else begin
            ms_min <= ms_min + 1;
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