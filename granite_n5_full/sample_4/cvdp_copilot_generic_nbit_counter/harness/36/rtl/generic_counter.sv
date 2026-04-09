module generic_counter #(parameter N = 8) (
    input logic clk_in,          // Clock input
    input logic rst_in,          // Active HIGH Reset input
    input logic [2:0] mode_in,   // Mode input (3 bits)
    input logic enable_in,       // Enable input
    input logic [N-1:0] ref_modulo, // Reference modulo value for Modulo-256 counter
    output logic [N-1:0] o_count   // Output count (N bits)
);

    parameter BINARY_UP = 3'b000;
    parameter BINARY_DOWN = 3'b001;
    parameter MODULO_256 = 3'b010;
    parameter JOHNSON = 3'b100;
    parameter GRAY = 3'b101;
    parameter RING = 3'b110;

    logic [N-1:0] count;

    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            count <= {N{1'b0}};
        end else begin
            case (mode_in)
                BINARY_UP: begin
                    if (count == {N{1'b0}}) begin
                        count <= {{(N-1){1'b0}}, 1'b1};
                    end else begin
                        count <= count+1;
                    end
                end

                BINARY_DOWN: begin
                    if (count == {N{1'b0}}) begin
                        count <= {N{1'b0}};
                    end else begin
                        count <= count+1;
                    end
                end

                MODULO_256: begin
                    count <= {N{1'b0}};
                end

                JOHNSON: begin
                    if (count > ref_modulo) begin
                        count <= {N{1'b0}};
                    end else begin
                        count <= count+1;
                    end
                end

                GRAY: begin
                    if (count % 2 == 0) begin
                        count <= count+1;
                    end else begin
                        count <= count/2;
                    end
                end

                RING: begin
                    if (count > ref_modulo) begin
                        count <= {N{1'b0}};
                    end else begin
                        count <= count+1;
                    end
                end
            endcase
        end
    endfunction