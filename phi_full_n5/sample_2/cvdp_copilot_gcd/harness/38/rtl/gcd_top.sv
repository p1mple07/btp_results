module gcd_top #(
   parameter WIDTH = 4,
   parameter DELTA_AREA_W = 12,
   parameter DELTA_AREA_CELL = 6
) (
   input                     clk,
   input                     rst,
   input                     go,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   output logic  [WIDTH-1:0] OUT,
   output logic             done
);

   logic [1:0] state;
   logic equal, greater_than;

   always @(posedge clk or posedge rst) begin
      if (rst) begin
         state <= 2'b00;
         equal <= 1'b0;
         greater_than <= 1'b0;
         OUT <= 'b0;
         done <= 1'b0;
      end else if (go) begin
         if (equal) begin
            state <= 2'b01;
            OUT <= A;
            done <= 1'b0;
         end else if (greater_than) begin
            state <= 2'b10;
            OUT <= B;
            done <= 1'b0;
         end else begin
            state <= 2'b11;
            OUT <= A - B;
            done <= 1'b1;
         end
      end
   end

endmodule
