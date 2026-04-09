module gcd_top #(
  parameter WIDTH = 4
) (
  input                     clk,
  input                     rst,
  input  [WIDTH-1:0]        A,
  input  [WIDTH-1:0]        B,
  input                     go,
  output logic  [WIDTH-1:0] OUT,
  output logic              done
);

  reg clk_en;
  reg [WIDTH-1:0] A_ff, B_ff;
  reg [1:0] controlpath_state;

  always_ff @(posedge clk) begin
    if (rst) begin
      clk_en <= 1'b0;
      A_ff <= 4'b0;
      B_ff <= 4'b0;
      OUT <= 4'b0;
      done <= 0;
    end else begin
      case (controlpath_state)
        2'd0: begin
          if (go) begin
            A_ff <= A;
            B_ff <= B;
          end
          equal <= A == B;
          greater_than <= A > B;
          done <= 0;
        end
        2'd1: begin
          case (equal)
            1'b0: begin
              if (A > B) begin
                A_ff <= A - B;
                B_ff <= 0;
                next_state = 2'd2;
              end else begin
                next_state = 2'd3;
              end
            end
          endcase
        end
        2'd2: begin
          if (A_ff == B_ff) begin
            OUT <= A_ff;
            done <= 1'b1;
          end
          endcase
        end
        2'd3: begin
          if (B_ff == A_ff) begin
            OUT <= B_ff;
            done <= 1'b1;
          end
          endcase
        end
      endcase
    end
  end

  always_comb begin
    assign controlpath_state = (A_ff == B_ff) ? 2'd1 : (A_ff > B_ff) ? 2'd2 : (B_ff > A_ff) ? 2'd3 : 2'd0;
  end

endmodule
