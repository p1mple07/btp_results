module wishbone_to_ahb_bridge(
    input clk_i,
    input rst_i,
    input cyc_i,
    input stb_i,
    input [3:0] sel_i,
    input we_i,
    input [31:0] addr_i,
    input [31:0] data_i,
    output reg ack_o,
    output reg [31:0] data_o,
    output reg [1:0] htrans,
    output reg [2:0] hsize,
    output reg hburst,
    output reg hwrite,
    output reg [31:0] haddr,
    output reg [31:0] hdata
);

  // Internal signals
  reg [31:0] a_addr, a_data, b_addr, b_data;
  reg [31:0] a_data_i, b_data_i;
  reg [1:0] state, next_state;
  reg [2:0] hsize_value;

  // Endian conversion helper
  function [31:0] little_to_big(input [31:0] data);
    begin
      little_to_big = data;
    end
  endfunction

  function [31:0] big_to_little(input [31:0] data);
    begin
      big_to_little = data;
    end
  endfunction

  // State machine for transaction phases
  always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      state <= IDLE;
      ack_o <= 1'b0;
      hwrite <= 1'b0;
      hsize_value <= 3'b000;
      htrans <= 2'b00;
      haddr <= 32'h0;
      hdata <= 32'h0;
    end else begin
      state <= next_state;
    end
  end

  // State transition logic
  always @(state, sel_i) begin
    case (state)
      IDLE: begin
        if (cyc_i && stb_i) begin
          ack_o <= 1'b0;
          next_state <= NON_SEQUENTIAL;
        end else begin
          ack_o <= 1'b0;
          next_state <= IDLE;
        end
      end
      NON_SEQUENTIAL: begin
        if (we_i) begin
          // Address fixing and data handling
          a_addr = {sel_i, addr_i};
          a_data_i = big_to_little(data_i);
          b_addr = a_addr;
          b_data_i = a_data_i;

          // Send AHB signals
          htrans <= 2'b01;
          hsize_value <= hsize;
          hburst <= 3'b000;
          hwrite <= 1'b1;
          haddr <= b_addr;
          hdata <= b_data_i;

          ack_o <= 1'b1;
          next_state <= BUSY;
        end else begin
          next_state <= IDLE;
        end
      end
      BUSY: begin
        if (hready) begin
          // Receive AHB signals
          hdata <= little_to_big(hdata);
          ack_o <= 1'b1;
          next_state <= IDLE;
        end else begin
          next_state <= NON_SEQUENTIAL;
        end
      end
    endcase
  end

endmodule
