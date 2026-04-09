module run_length
#(
    parameter DATA_WIDTH = 8                        // Width of the output run-length counter
)
(
    input wire clk,
    input wire reset_n,
    input wire data_in,
    output reg data_out,
    output reg [$clog2(DATA_WIDTH):0] run_value,
    output reg valid
);

    reg [$clog2(DATA_WIDTH):0] run_length;
    reg prev_data_in;

    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            run_length   <= 'b0;           
            run_value    <= 'b0;	       
            prev_data_in <= 1'b0;			               
        end
        else begin
            if (!reset_n) begin
                // This block is redundant, but we can keep it.
            end
            if (data_in == prev_data_in) begin
                run_length++;
            else begin
                run_length = 1;
                run_value <= prev_data_in;
                prev_data_in = data_in;
            end
            if (run_length == DATA_WIDTH) begin
                run_value <= 1'b0;
            }
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out <= 1'b0;
            valid <= 1'b0;
        end else begin
            data_out <= data_in;
            valid <= ~prev_data_in;
        end
    end

endmodule
