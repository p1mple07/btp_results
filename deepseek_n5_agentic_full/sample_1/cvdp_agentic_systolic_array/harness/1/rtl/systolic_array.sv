`timescale 1ns/1ns

module systolic_array (
    // Internal variables
    parameter DATA_WIDTH = 8,
    parameterNum  CLOCK_PERIOD = 10,

    // Top level interconnections
    reg [DATA_WIDTH-1:0] input_in_row0, input_in_row1,
                         input_in_col0, input_in_col1,
                         output_in_row0, output_in_row1;
    
    reg [DATA_WIDTH-1:0] psum_in_row0, psum_in_row1,
                         psum_in_col0, psum_in_col1;
    
    // PE0: top-left PE
    inst_pe0 = 
        module weight_stationary_pe #(
            parameter DATA_WIDTH = DATA_WIDTH
        ) (
            inputclk(clk),
            rst(reset),
            loadw(1'b0),
            start(1'b0),
            w00(0),
            w01(0),
            w10(0),
            w11(0),
            x0(input_in_row0),
            x1(input_in_row1),
            y0(output_in_row0),
            y1(output_in_row1),
            done
        );
        
    // PE1: top-right PE
    inst_pe1 = 
        module weight_stationary_pe #(
            parameter DATA_WIDTH = DATA_WIDTH
        ) (
            inputclk(clk),
            rst(reset),
            loadw(1'b0),
            start(1'b0),
            w00(0),
            w01(0),
            w10(0),
            w11(0),
            x0(input_in_row1),
            x1(input_in_row0),
            y0(output_in_row1),
            y1(output_in_row0),
            done
        );
        
    // PE2: bottom-left PE
    inst_pe2 = 
        module weight_stationary_pe #(
            parameter DATA_WIDTH = DATA_WIDTH
        ) (
            inputclk(clk),
            rst(reset),
            loadw(1'b0),
            start(1'b0),
            w00(0),
            w01(0),
            w10(0),
            w11(0),
            x0(output_in_row0),
            x1(output_in_row1),
            y0(output_in_row0),
            y1(output_in_row1),
            done
        );
        
    // PE3: bottom-right PE
    inst_pe3 = 
        module weight_stationary_pe #(
            parameter DATA_WIDTH = DATA_WIDTH
        ) (
            inputclk(clk),
            rst(reset),
            loadw(1'b0),
            start(1'b0),
            w00(0),
            w01(0),
            w10(0),
            w11(0),
            x0(output_in_row1),
            x1(output_in_row0),
            y0(output_in_row1),
            y1(output_in_row0),
            done
        );
        
    // Internal wires
    // Row-wise communication
    psum_out_row0 <= psum_in_row0;
    psum_out_row1 <= psum_in_row1;
    
    psum_in_col0 <= psum_out_row0;
    psum_in_col1 <= psum_out_row1;
    
    output_in_row0 <= psum_out_row0;
    output_in_row1 <= psum_out_row1;
)

  // Top-level signals
  reg [DATA_WIDTH-1:0] input_in_row0, input_in_row1,
                         output_in_row0, output_in_row1;
  reg [DATA_WIDTH-1:0] psum_in_row0, psum_in_row1,
                         psum_in_col0, psum_in_col1;
  reg y0, y1;
  
  // Control signals
  regrst(reset),
  regclk(clk),
  regstart(start),
  regload_weights(load_weight),
  regdone(done);

  // instantiate and configure the processing elements
  instantiated
    inst_pe0, inst_pe1, inst_pe2, inst_pe3;
    
  // Configure PE0 to handle top-left portion of matrix multiplication
  pe0.loadw <= 1'b0;
  pe0.start <= 1'b0;
  
  // Configure PE1 to handle top-right portion
  pe1.loadw <= 1'b0;
  pe1.start <= 1'b0;
  
  // Configure PE2 to handle bottom-left portion
  pe2.loadw <= 1'b0;
  pe2.start <= 1'b0;
  
  // Configure PE3 to handle bottom-right portion
  pe3.loadw <= 1'b0;
  pe3.start <= 1'b0;
  
  // Setup data flow between PEs
  pe0.psum_out <= pe0.y_reg;
  pe1.psum_out <= pe1.y_reg;
  pe2.psum_out <= pe2.y_reg;
  pe3.psum_out <= pe3.y_reg;
  
  pe0.x_reg <= input_in_row0;
  pe1.x_reg <= input_in_row1;
  pe2.x_reg <= output_in_row0;
  pe3.x_reg <= output_in_row1;
  
  // Final outputs
  output_in_row0 <= pe0.y_reg;
  output_in_row1 <= pe1.y_reg;
  
  // Clock enablement
  pe0.reset <= reset;
  pe1.reset <= reset;
  pe2.reset <= reset;
  pe3.reset <= reset;
  
  // Synchronize clocks
  pe0.clk <= ck;
  pe1.clk <= ck;
  pe2.clk <= ck;
  pe3.clk <= ck;
  
  // System start control
  start <= 1'b0;
  #5
  start <= 1'b1;
  #5
  start <= 1'b0;