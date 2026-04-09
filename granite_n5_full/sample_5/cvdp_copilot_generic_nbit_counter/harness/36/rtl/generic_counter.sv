module generic_counter #(
    parameter N = 8
)(
    input logic clk_in,          // Clock input
    input logic rst_in,          // Active HIGH Reset input
    input logic [2:0] mode_in,   // Mode input (3 bits)
    input logic enable_in,     // Enable input
    input logic [N-1:0] ref_modulo, // Reference modulo value for Modulo-256 counter
    output logic [N-1:0] o_count   // Output count (N bits)
);

    localparam BINARY_UP = 3'b000;
    localparam BINARY_DOWN = 3'b001;
    localparam MODULO_256 = 3'b010;
    localparam JOHNSON = 3'b100;
    localparam GRAY = 3'b101;
    localparam RING = 3'b010;
    
    logic [N-1:0] count;

    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            count <= {N{1'b0}};
        end else begin
            case (mode_in)
                BINARY_UP: begin
                    if (enable_in) begin
                        count <= count + 1;
                    end else begin
                        count <= count;
                    end
                end
                BINARY_DOWN: begin
                    if (enable_in) begin
                        count <= count - 1;
                    end else begin
                        count <= count;
                    end
                end
                MODULO_256: begin
                    if (enable_in) begin
                        count <= {count, ref_modulo};
                    end else begin
                        count <= count;
                    end
                end
                JOHNSON: begin
                    if (enable_in) begin
                        count <= ~count[0];
                    end else begin
                        count <= count;
                    end
                end
                GRAY: begin
                    if (enable_in) begin
                        if (count[N-1:0] == 0) begin
                            count <= {N{1'b0}};
                        end else begin
                            count <= count;
                        end
                end
                RING: begin
                    if (count[N-1:0] < count[N-1:0]) begin
                        count <= count;
                    end else begin
                        count <= count;
                    end
                end
            end
        end
    end
endmodule