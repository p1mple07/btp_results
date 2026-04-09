module clock_divider (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [1:0]  sel,
    output logic        clk_out
);

  // Counter used for division factors 4 and 8 (needs 3 bits for max count 7)
  reg [2:0] counter;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      clk_out  <= 1'b0;
      counter  <= 3'd0;
    end else begin
      if (sel == 2'b00) begin
        // Divide by 2: Toggle clk_out on every clock edge.
        clk_out <= ~clk_out;
      end else if (sel == 2'b01) begin
        // Divide by 4: Use a 3-bit counter that counts 0,1,2 then resets.
        counter <= (counter == 3'd2) ? 3'd0 : counter + 3'd1;
        // Toggle output when counter equals 1 (every 2 cycles)
        if (counter == 3'd1)
          clk_out <= ~clk_out;
      end else if (sel == 2'b10) begin
        // Divide by 8: Use a 3-bit counter that counts 0..6 then resets.
        counter <= (counter == 3'd6) ? 3'd0 : counter + 3'd1;
        // Toggle output when counter equals 3 (every 4 cycles)
        if (counter == 3'd3)
          clk_out <= ~clk_out;
      end else begin
        // Invalid sel: hold clk_out at 0
        clk_out <= 1'b0;
      end
    end
  end

endmodule