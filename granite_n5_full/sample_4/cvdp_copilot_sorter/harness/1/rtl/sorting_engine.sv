module sorting_engine #(
  parameter N = 8, // Number of elements to sort
  parameter WIDTH = 8 // Bit-width of each input element
) (
  input wire clk,
  input wire rst,
  input wire start,
  input wire [N*WIDTH-1:0] in_data,
  output logic done,
  output wire [N*WIDTH-1:0] out_data
);

  logic [N*WIDTH-1:0] sorted_data;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      sorted_data <= {N{WIDTH{1'b0}}}; // Initialize to all zeros
    end else if (start) begin
      // Perform bubble sort on in_data
      for (int i = 0; i < N-1; i++) begin
        for (int j = 0; j < N-i-1; j++) begin
          if (in_data[j*WIDTH+:WIDTH] > in_data[(j+1)*WIDTH+:WIDTH]) begin
            // Swap elements
            sorted_data[j*WIDTH+:WIDTH] <= in_data[(j+1)*WIDTH+:WIDTH];
            sorted_data[(j+1)*WIDTH+:WIDTH] <= in_data[j*WIDTH+:WIDTH];
          end
        end
      end

      done <= 1'b1;
    end
  end

  assign out_data = sorted_data;

endmodule