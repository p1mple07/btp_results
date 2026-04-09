module password_generator #(
    parameter WIDTH = 4  
) (
    input logic clk,
    input logic reset,
    output logic [(WIDTH*8)-1:0] password 
);

  logic [7:0] char_array[WIDTH-1:0];  
  logic [7:0] counter;  
  logic [1:0] char_type; 

  int i;

  // Counter logic for pseudo-random generation
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end

  // Generate password characters
  assign char_type = counter[1:0];
  assign char_array = {char_type, char_type};
  for(i=0; i<WIDTH-1; i=i+1) begin
    assign char_array[i] = ((counter + char_array[(i+1)%WIDTH]) % 26) + 8'd97;
  end
  
  assign password = {{8{counter[1]}}, char_array};

endmodule