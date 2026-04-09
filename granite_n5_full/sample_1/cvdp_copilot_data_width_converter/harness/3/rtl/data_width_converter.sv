module data_width_converter (
  input wire clk,
  input wire reset,
  input wire [31:0] data_in,
  input wire data_valid,
  output reg [127:0] o_data_out,
  output reg o_data_out_valid
);

  reg [31:0] data_buffer [3:0];
  reg [3:0] data_buffer_count;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      data_buffer <= '{default:'0};
      data_buffer_count <= 0;
      o_data_out_valid <= 0;
    end else begin
      if (data_valid && data_buffer_count < 4) begin
        data_buffer[data_buffer_count] <= data_in;
        data_buffer_count <= data_buffer_count + 1;
      end

      if (data_buffer_count == 4) begin
        o_data_out <= {{(4*32)-1{data_buffer[0][31]}}, data_buffer[0], data_buffer[1], data_buffer[2], data_buffer[3]};
        o_data_out_valid <= 1;
        data_buffer <= '{default:'0};
        data_buffer_count <= 0;
      end
    end
  end
endmodule