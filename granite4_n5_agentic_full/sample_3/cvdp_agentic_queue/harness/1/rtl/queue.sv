module queue #(
  // Parameters
  parameter int Depth = 8,
  parameter int DataBits = 32,
  parameter int AlmostEmptyThreshold = Depth / 4,
  parameter int AlmostFullThreshold = Depth * 3 / 4
) (
  // Inputs
  input wire clk_i,
  input wire rst_ni,
  input wire clr_i,
  input wire ena_i,
  input wire we_i,
  input wire [DataBits-1:0] d_i,
  input wire re_i,
  
  // Outputs
  output logic empty_o,
  output logic full_o,
  output logic almost_empty_o,
  output logic almost_full_o,
  output logic [DataBits-1:0] q_o
);

  // Define local parameters
  localparam int MaxDepth = 2**Depth;

  // Internal state variables
  reg [Depth-1:0] data_reg;
  reg [Depth-1:0] wadr;

  // Update queue pointer based on read operation
  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      wadr <= '0;
    end else if (re_i) begin
      if (wadr == 0) begin
        wadr <= MaxDepth-1;
      } else begin
        wadr <= wadr - 1;
      end
    end
  end

  // Update status signals
  assign empty_o = (wadr == 0);
  assign full_o = (wadr == MaxDepth-1);
  assign almost_empty_o = ((wadr + AlmostEmptyThreshold) < MaxDepth && almost_empty_threshold_met());
  assign almost_full_o = ((wadr - AlmostFullThreshold) > 0 && almost_full_threshold_met());

  // Determine if almost-empty or almost-full condition is met
  function automatic bit almost_empty_threshold_met();
    return (wadr >= AlmostEmptyThreshold);
  endfunction

  function automatic bit almost_full_threshold_met();
    return (wadr >= (MaxDepth - AlmostFullThreshold));
  endfunction

  // Update queue data based on write operation
  always @(posedge clk_i or posedge rst_ni or posedge clr_i) begin
    if (!rst_ni) begin
      wadr <= '0;
    end else if (we_i &&!clr_i) begin
      if (wadr == 0) begin
        q_o <= d_i;
      end else begin
        data_reg[wadr-1:0] <= d_i;
      end
    end
  end

  // Assign shifted output based on read operation
  always @* begin
    if (re_i) begin
      if (wadr == 0) begin
        q_o <= data_reg[DataBits-1:0];
      end else begin
        q_o <= data_reg[(wadr - 1):0];
      end
    end
  end

endmodule