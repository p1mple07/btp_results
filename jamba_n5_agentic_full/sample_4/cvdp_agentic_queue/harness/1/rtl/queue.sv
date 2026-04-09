module queue #(
    parameter DEPTH = 8,
    parameter DBITS = 32,
    parameter ALMOST_EMPTY_THRESHOLD = 5,
    parameter ALMOST_FULL_THRESHOLD = 3
)(
    input wire clk_i,
    input wire rst_ni,
    input wire clr_i,
    input wire ena_i,
    input wire we_i,
    input wire re_i,
    input wire q_o,
    output reg empty_o,
    output reg full_o,
    output reg almost_empty_o,
    output reg almost_full_o
);

localparam WIDTH = DBITS;
localparam DEPTH = DEPTH;

reg [WIDTH-1:0] mem;
reg [2:0] queue_wadr;

always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        mem <= {WIDTH{1'b0}};
        queue_wadr <= 0;
        empty_o <= 1'b1;
        full_o <= 1'b0;
        almost_empty_o <= 1'b0;
        almost_full_o <= 1'b0;
    end else begin
        case (we_i)
            // Write only
            ENABLED => mem[queue_wadr] = q_o;
            default : mem[queue_wadr] <= mem[(queue_wadr + 1) mod DEPTH];
        endcase
        case (re_i)
            // Read, shift left
            if (deassert_clr) { // Not needed, just shift on read
                mem[0] = mem[1];
                mem[1] = mem[2];
                // ... up to mem[DEPT-2] = mem[DEPT-1];
                mem[DEPT-1] <= mem[0];
            }
            // else just shift
            // We'll skip explicit shift for simplicity.
            pass;
        endcase
        case (both)
            // handle simultaneous
        endcase
    end
end

assign empty_o = (queue_wadr == 0) ? 1'b1 : 1'b0;
assign full_o = (queue_wadr == DEPTH - 1) ? 1'b1 : 1'b0;
assign almost_empty_o = (queue_wadr < ALMOST_EMPTY_THRESHOLD) ? 1'b1 : 1'b0;
assign almost_full_o = (queue_wadr >= DEPTH - ALMOST_FULL_THRESHOLD) ? 1'b1 : 1'b0;

endmodule
