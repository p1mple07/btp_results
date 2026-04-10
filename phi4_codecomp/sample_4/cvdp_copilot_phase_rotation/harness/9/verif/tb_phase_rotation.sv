module tb_phase_rotation;

   parameter NBW_IN_DATA  = 8;
   parameter NBW_COS      = 8;
   parameter NBW_MULT     = NBW_IN_DATA + NBW_COS;
   parameter NBW_SUM      = NBW_MULT + 1;
   parameter NBW_OUT_DATA = NBW_SUM;

   logic clk;
   logic signed [NBW_IN_DATA-1:0]  i_data_re;
   logic signed [NBW_IN_DATA-1:0]  i_data_im;
   logic signed [NBW_COS-1:0]      i_cos;
   logic signed [NBW_COS-1:0]      i_sin;
   logic signed [NBW_OUT_DATA-1:0] o_data_re;
   logic signed [NBW_OUT_DATA-1:0] o_data_im;

   phase_rotation #(
      .NBW_IN_DATA(NBW_IN_DATA),
      .NBW_COS(NBW_COS),
      .NBW_MULT(NBW_MULT),
      .NBW_SUM(NBW_SUM),
      .NBW_OUT_DATA(NBW_OUT_DATA)
   ) dut (
      .clk(clk),
      .i_data_re(i_data_re),
      .i_data_im(i_data_im),
      .i_cos(i_cos),
      .i_sin(i_sin),
      .o_data_re(o_data_re),
      .o_data_im(o_data_im)
   );

   initial begin
      clk = 0;
      forever #5 clk = ~clk;
   end

   typedef struct packed {
      logic signed [NBW_OUT_DATA-1:0] expected_re;
      logic signed [NBW_OUT_DATA-1:0] expected_im;
   } expected_outputs_t;

   function automatic expected_outputs_t calculate_expected_outputs(
      input signed [NBW_IN_DATA-1:0]  data_re,
      input signed [NBW_IN_DATA-1:0]  data_im,
      input signed [NBW_COS-1:0]      cos_val,
      input signed [NBW_COS-1:0]      sin_val
   );
      logic signed [NBW_MULT-1:0] data_a;
      logic signed [NBW_MULT-1:0] data_b;
      logic signed [NBW_MULT-1:0] data_c;
      logic signed [NBW_MULT-1:0] data_d;

      data_a = cos_val * data_re;
      data_b = sin_val * data_im;
      data_c = sin_val * data_re;
      data_d = cos_val * data_im;

      calculate_expected_outputs.expected_re = data_a - data_b;
      calculate_expected_outputs.expected_im = data_c + data_d;
   endfunction

   task apply_inputs_and_check(
      input logic signed [NBW_IN_DATA-1:0]  data_re,
      input logic signed [NBW_IN_DATA-1:0]  data_im,
      input logic signed [NBW_COS-1:0]      cos_val,
      input logic signed [NBW_COS-1:0]      sin_val
   );
      expected_outputs_t expected;

      begin
         i_data_re = data_re;
         i_data_im = data_im;
         i_cos     = cos_val;
         i_sin     = sin_val;

         expected = calculate_expected_outputs(data_re, data_im, cos_val, sin_val);

         @(posedge clk);
         @(posedge clk);
         @(posedge clk);

         if (o_data_re !== expected.expected_re) begin
            $display("Erro: o_data_re expected = %0d, received = %0d", expected.expected_re, o_data_re);
         end else begin
            $display("o_data_re correct: %0d", o_data_re);
         end

         if (o_data_im !== expected.expected_im) begin
            $display("Erro: o_data_im ex = %0d, received = %0d", expected.expected_im, o_data_im);
         end else begin
            $display("o_data_im correct: %0d", o_data_im);
         end
      end
   endtask

   initial begin
      $dumpfile("phase_rotation_tb.vcd");
      $dumpvars(0, tb_phase_rotation);

      apply_inputs_and_check(8'sd10, 8'sd5, 8'sd3, 8'sd4);
      apply_inputs_and_check(-8'sd7, 8'sd2, 8'sd6, -8'sd1);
      apply_inputs_and_check(8'sd127, -8'sd128, 8'sd127, -8'sd128);
      apply_inputs_and_check(8'sd0, 8'sd0, 8'sd0, 8'sd0);
      apply_inputs_and_check(8'sd127, 8'sd0, 8'sd127, 8'sd0);
      apply_inputs_and_check(-8'sd128, -8'sd128, 8'sd0, 8'sd127);
      apply_inputs_and_check(8'sd127, 8'sd127, -8'sd128, -8'sd128);
      apply_inputs_and_check(8'sd1, -8'sd1, -8'sd1, 8'sd1);
      #20;
      $finish;
   end
endmodule