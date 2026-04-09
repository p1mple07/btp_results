module queue #(
    parameter int DEPTH = 8,
    parameter int DBITS = 8
) (
    input clk_i,
    input rst_ni,
    input ena_i,
    input we_i,
    input d_i,
    input re_i,
    input q_o,
    output reg empty_o,
    output reg full_o,
    output reg almost_empty_o,
    output reg almost_full_o
);

reg [DEPTH-1:0] queue_data;
reg [0:0] queue_ptr = 0;

always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        queue_ptr <= 0;
        queue_data[0] <= 0;
        empty_o <= 1;
        full_o <= 0;
        almost_empty_o <= 0;
        almost_full_o <= 0;
    end else begin
        if (we_i) begin
            // Write operation
            queue_data[queue_ptr] <= d_i;
            queue_ptr = (queue_ptr + 1) mod DEPTH;
        end else if (re_i) begin
            // Read operation
            empty_o <= (queue_ptr == 0);
            full_o <= (queue_ptr == DEPTH - 1);
            q_o <= queue_data[0];
        end else if (ena_i) begin
            // Sync read/write
            if (we_i && re_i) begin
                // Simultaneous: shift and insert
                // Shift left
                for (int i = 0; i < DEPTH - 1; i++) queue_data[i+1] <= queue_data[i];
                queue_data[0] <= d_i;
                // Insert new data at front
                queue_data[1] <= queue_data[0];
            end
        end else if (q_o) begin
            q_o <= queue_data[0];
        end
    end
end

endmodule
