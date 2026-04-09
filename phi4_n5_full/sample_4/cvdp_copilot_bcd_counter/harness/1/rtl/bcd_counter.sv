module bcd_counter(
    input  logic         clk,
    input  logic         rst,
    output logic [3:0]   ms_hr,  // Most significant digit of hour (tens)
    output logic [3:0]   ls_hr,  // Least significant digit of hour (units)
    output logic [3:0]   ms_min, // Most significant digit of minute (tens)
    output logic [3:0]   ls_min, // Least significant digit of minute (units)
    output logic [3:0]   ms_sec, // Most significant digit of second (tens)
    output logic [3:0]   ls_sec  // Least significant digit of second (units)
);

  // On reset, all counters are set to 0 (00:00:00)
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      ms_hr  <= 4'd0;
      ls_hr  <= 4'd0;
      ms_min <= 4'd0;
      ls_min <= 4'd0;
      ms_sec <= 4'd0;
      ls_sec <= 4'd0;
    end else begin
      // Increment seconds
      if (ls_sec == 4'd9) begin
        ls_sec <= 4'd0;
        if (ms_sec == 4'd5) begin
          ms_sec <= 4'd0;
          // Increment minutes
          if (ls_min == 4'd9) begin
            ls_min <= 4'd0;
            if (ms_min == 4'd5) begin
              ms_min <= 4'd0;
              // Increment hours
              if (ms_hr < 4'd2) begin
                ms_hr <= ms_hr + 1;
              end else begin // ms_hr == 2, hour tens digit is 2
                if (ls_hr < 4'd3) begin
                  ls_hr <= ls_hr + 1;
                end else begin
                  // When hour reaches 23 (i.e. ms_hr==2 and ls_hr==3),
                  // reset the entire clock to 00:00:00.
                  ms_hr  <= 4'd0;
                  ls_hr  <= 4'd0;
                  ms_min <= 4'd0;
                  ls_min <= 4'd0;
                  ms_sec <= 4'd0;
                  ls_sec <= 4'd0;
                end
              end
            end else begin
              ms_min <= ms_min + 1;
            end
          end else begin
            ls_min <= ls_min + 1;
          end
        end else begin
          ms_sec <= ms_sec + 1;
        end
      end else begin
        ls_sec <= ls_sec + 1;
      end
    end
  end

endmodule