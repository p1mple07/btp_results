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

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ms_sec <= 0;
            ls_sec <= 0;
            ms_min <= 0;
            ls_min <= 0;
            ms_hr  <= 0;
            ls_hr  <= 0;
        end else begin
            // Increment seconds
            if (ls_sec < 9) begin
                ls_sec <= ls_sec + 1;
            end else begin
                ls_sec <= 0;
                if (ms_sec < 5) begin
                    ms_sec <= ms_sec + 1;
                end else begin
                    ms_sec <= 0;
                    // Seconds rolled over; increment minutes
                    if (ls_min < 9) begin
                        ls_min <= ls_min + 1;
                    end else begin
                        ls_min <= 0;
                        if (ms_min < 5) begin
                            ms_min <= ms_min + 1;
                        end else begin
                            ms_min <= 0;
                            // Minutes rolled over; increment hours
                            if (ls_hr < 3) begin
                                ls_hr <= ls_hr + 1;
                            end else begin
                                ls_hr <= 0;
                                if (ms_hr < 2) begin
                                    ms_hr <= ms_hr + 1;
                                end else begin
                                    ms_hr <= 0;
                                    // Full day elapsed (23:59:59); reset entire clock
                                    ms_sec <= 0;
                                    ls_sec <= 0;
                                    ms_min <= 0;
                                    ls_min <= 0;
                                end
                            end
                        end
                    end
                end
            end
        end
    end

endmodule