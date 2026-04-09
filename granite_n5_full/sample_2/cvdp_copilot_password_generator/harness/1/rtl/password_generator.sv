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

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      counter <= 0;
      password <= 0;
    end else begin
      counter <= counter + 1;
      
      case (char_type)
        2'b00: char_array <= $urandom() % 26 + 97;  
        2'b01: char_array <= $urandom() % 26 + 65;   
        2'b10: char_array <= $urandom() % 14 + 33; 
        2'b11: char_array <= $urandom() % 10 + 48; 
      endcase
      
      for (i=0; i<WIDTH; i++) begin
        password[i*8+:8] <= char_array[i];
      end
    end
  end

endmodule