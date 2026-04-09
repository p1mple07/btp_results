module swizzler_supervisor #(
  parameter integer NUM_LANES           = 4,
  parameter integer DATA_WIDTH          = 8,
  parameter integer REGISTER_OUTPUT     = 1,
  parameter integer ENABLE_PARITY_CHECK = 1,
  parameter integer OP_MODE_WIDTH       = 2,
  parameter integer SWIZZLE_MAP_WIDTH   = $clog2(NUM_LANES)+1,
  parameter [DATA_WIDTH-1:0] EXPECTED_CHECKSUM = 8'hA5
)(
  input  wire                           clk,
  input  wire                           rst_n,
  input  wire                           bypass,
  input  wire [NUM_LANES*DATA_WIDTH-1:0] data_in,
  input  wire [NUM_LANES*SWIZZLE_MAP_WIDTH-1:0] swizzle_map_flat,
  input  wire [OP_MODE_WIDTH-1:0]         operation_mode,
  output reg  [NUM_LANES*DATA_WIDTH-1:0]  final_data_out,
  output reg                            top_error
);
  // Module internals
  wire [NUM_LANES*DATA_WIDTH-1:0] data_out;
  wire [NUM_LANES*SWIZZLE_MAP_WIDTH-1:0] swizzle_map_flat_wired;
  wire [NUM_LANES*DATA_WIDTH-1:0] validity_mask;
  reg [NUM_LANES*DATA_WIDTH-1:0] valid;
  reg [NUM_LANES*DATA_WIDTH-1:0] final_output;
  
  // Parity computation
  function automatic [NUM_LANES*DATA_WIDTH-1:0] compute_checksum(const wire [*] lanes) {
    wire [*] temp_lanes;
    integer i;
    for (i = 0; i < NUM_LANES; i = i + 1) {
      temp_lanes[i] = lanes[i];
    }
    
    final_output = ((temp_lanes[0] >> (DATA_WIDTH-1)) & 1) |
                   ((temp_lanes[1] >> (DATA_WIDTH-1)) & 1) |
                   ((temp_lanes[2] >> (DATA_WIDTH-1)) & 1) |
                   ((temp_lanes[3] >> (DATA_WIDTH-1)) & 1);
    
    return final_output;
  endfunction
  
  // Parity check logic
  reg parity_ok = 1'b1;
  reg validity_ok = 1'b1;
  
  // Data validation
  integer phase;
  always @* begin
    phase = 0;
    // Initial phase
    if (!rst_n) begin
      valid = 1;
      phase = 1;
    end
    
    // Processing phase
    case(phase)
      1: 
        valid = 1;
        data_out = data_in;
        phase = 2;
        continue;
      
      2: 
        valid = 1;
        data_out = swizzle_out ^ data_out;
        phase = 3;
        continue;
      
      default: 
        valid = 0;
        break;
    endcase
    
    // Compute checksum
    validity_ok = 1;
    parity_ok = compute_checksum(final_output);
    
    // Check against expected checksum
    if (validity_ok && parity_ok == EXPECTED_CHECKSUM) {
      parity_error = 0;
    } else {
      parity_error = 1;
    }
  endalways

  // Final validation
  final_output = valid ? data_out : 0;
  
  // Connect to swizzler
  wire [NUM_LANES*DATA_WIDTH-1:0] data_out_swpz;
  wire [NUM_LANES*SWIZZLE_MAP_WIDTH-1:0] swizzle_map_flat_wired_swpz;
  wire [NUM_LANES*SWIZZLE_MAP_WIDTH-1:0] swizzle_map_flat_swpz;
  wire [NUM_LANES*DATA_WIDTH-1:0] data_in_swpz;

  // instantiate the swizzler
  `include "swizzler.sv"
  swizzler dut (
    .clk(clk),
    .rst_n(rst_n),
    .bypass(bypass),
    .data_in(data_in_swpz),
    .swizzle_map_flat(swizzle_map_flat_wired_swpz),
    .operation_mode(operation_mode),
    .data_out(data_out_swpz),
    .parity_error(parity_error),
    .invalid_mapping_error(validity_error)
  );
  
  // Additional interfaces
  assign final_data_out = final_output;
  assign top_error = parity_error;
  
  // Initialization
  initial begin
    // Queue initialization
    for (phase = 0; phase < 3; phase = phase + 1) begin
      valid = 0;
      data_out = 0;
      if (phase == 2) final_output = 0;
    end
    rst_n = 0;
    for (i = 0; i < 10; i = i + 1); // Warm-up period
      if (rst_n) continue;
      else @posedge(clk) begin
        if (!rst_n) begin
          for (j = 0; j < NUM_LANES; j = j + 1) begin
            swizzled[j] <= data_in[swizzled_src[j]];
          end
          phase = 2;
        end
      end
    end
  endinitial;
endmodule