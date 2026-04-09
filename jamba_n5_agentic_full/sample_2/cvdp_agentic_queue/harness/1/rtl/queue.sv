module queue #(
    parameter int DEPTH = 32,
    parameter int DBITS = 8
)(
    input  logic clk_i,
    input  logic rst_ni,
    input  logic clr_i,
    input  logic ena_i,
    input  logic we_i,
    input  logic d_i,
    input  logic re_i,
    output reg q_o,
    output reg empty_o,
    output reg full_o,
    output reg almost_empty_o,
    output reg almost_full_o
);

localparam int FULL_CAPACITY = DEPTH * DBITS;
localparam int THRESHOLD = FULL_CAPACITY / 2;

reg [DEPTH-1:0] queue_data;
reg [0:1] queue_wadr;
reg ena_active;

always_ff @(posedge clk_i) begin
    if (~rst_ni) begin
        queue_wadr <= 0;
        ena_active <= 1'b0;
        queue_data <= {};
        queue_data[0] <= 0;
    end else begin
        case (we_i)
            'W: queue_wadr <= queue_wadr + 1 mod DEPTH;
            'R: begin
                if (queue_wadr == 0)
                    queue_data[0] <= d_i;
                else
                    queue_data[queue_wadr] <= d_i;
                queue_wadr <= queue_wadr + 1 mod DEPTH;
            end
            'C: begin
                if (queue_wadr == FULL_CAPACITY)
                    ena_active <= 1'b0;
                else
                    ena_active <= 1'b1;
            end
        endcase
    end
end

always_comb begin
    q_o = queue_data[0];
    empty_o = ~queue_wadr && queue_wadr == 0;
    full_o = queue_wadr == FULL_CAPACITY;
    almost_empty_o = queue_wadr == 0;
    almost_full_o = queue_wadr == FULL_CAPACITY - 1;
end

assign ena_active = ena_i;

always_ff @(posedge clk_i) begin
    if (ena_active) begin
        if (we_i) begin
            queue_wadr <= queue_wadr + 1 mod DEPTH;
            if (queue_wadr == 0)
                queue_data[0] <= d_i;
            else
                queue_data[queue_wadr] <= d_i;
        end
        if (re_i) begin
            if (queue_wadr == 0)
                q_o <= queue_data[0];
            else
                assign queue_data[1] = queue_data[0];
                for (int i = 1; i < DEPTH; i++)
                    queue_data[i] = queue_data[i-1];
                q_o <= queue_data[0];
            end
        end
        if (full_o) begin
            ena_active <= 1'b0;
        end
    end
end

endmodule
