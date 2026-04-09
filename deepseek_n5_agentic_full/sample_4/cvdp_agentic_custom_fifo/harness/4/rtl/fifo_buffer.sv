module fifo_buffer #(
  parameter int unsigned NUM_OF_REQS = 2,
  parameter bit          ResetAll      = 1'b0
) (
  input  logic                clk_i,
  input  logic                rst_i,

  input  logic unsigned NUM_OF_REQS-1:0] busy_o,

  input logic [NUM_OF_REQS-1:0] reset_all_i,
  input logic [31:0]            in_valid_i,
  input logic [31:0]            in_addr_i,
  input logic [31:0]            in_rdata_i,
  input logic                in_err_i,

  output logic                out_valid_o,
  output logic [31:0]          out_addr_o,
  output logic [31:0]          out_rdata_o,
  output logic                out_err_o,
  output logic                out_err_plus2_o

  wire [31:0] rdata_d [0:FIFO_DEPTH-1];
  wire [31:31] err_d [0:FIFO_DEPTH-1];
  wire [FIFO_DEPTH-1:0] err_d, rdata_d;

  logic [31:0] rdata_d [0:FIFO_DEPTH-1];
  logic [31:31] err_d [0:FIFO_DEPTH-1];
  logic [FIFO_DEPTH-1:0] err_d, rdata_d;

  logic signed              FIFO/addrs;
  logic [FIFO_DEPTH-1:0]   err_d, valid_q;
  logic [FIFO_DEPTH-1:0]   low_valid_entry;
  logic [FIFO_DEPTH-1:0]   valid_pushed;
  logic [FIFO_DEPTH-1:0]   entry_en;

  logic [FIFO_DEPTH-1:0]   valid_q [0:FIFO_DEPTH-1];
  logic [FIFO_DEPTH-1:0]   valid_q [1:FIFO_DEPTH-2];
  logic [FIFO_DEPTH-1:0]   valid_q [FIFO_DEPTH-1:FIFO_DEPTH-1];
  logic [FIFO_DEPTH-1:0]   err_d [0:FIFO_DEPTH-1];
  logic [FIFO_DEPTH-1:0]   err_d [1:FIFO_DEPTH-2];
  logic [FIFO_DEPTH-1:0]   err_d [FIFO_DEPTH-1:FIFO_DEPTH-1];

  logic [FIFO_DEPTH-1:0]   rdata_d [0:FIFO_DEPTH-1];
  logic [FIFO_DEPTH-1:0]   rdata_d [1:FIFO_DEPTH-2];
  logic [FIFO_DEPTH-1:0]   rdata_d [FIFO_DEPTH-1:FIFO_DEPTH-1];
  logic [FIFO_DEPTH-1:0]   err_d [0:FIFO_DEPTH-1];
  logic [FIFO_DEPTH-1:0]   err_d [1:FIFO_DEPTH-2];
  logic [FIFO_DEPTH-1:0]   err_d [FIFO_DEPTH-1:FIFO_DEPTH-1];

  logic [FIFO_DEPTH-1:0]   low_valid_entry[i] = ~valid_q[i];
  logic [FIFO_DEPTH-1:0]   valid_pushed[i] = (in_valid_i & low_valid_entry[i]) | valid_q[i];
  logic [FIFO_DEPTH-1:0]   low_valid_is_compressed[i] = (rdata_d[i] != 2'b11);
  logic [FIFO_DEPTH-1:0]   valid_pushed[i] = valid_q[i] | in_valid_i;

  logic [FIFO_DEPTH-1:0]   rdata_d[i] = valid_q[i+1] ? rdata_i : in_rdata_i;
  logic [FIFO_DEPTH-1:0]   err_d[i] = valid_q[i+1] ? err_q[i+1] : in_err_i;

  logic [FIFO_DEPTH-1:0]   rdata_d[i] = valid_q[i+1] ? rdata_i : in_rdata_i;
  logic [FIFO_DEPTH-1:0]   err_d[i] = valid_q[i+1] ? err_q[i+1] : in_err_i;

  logic [FIFO_DEPTH-1:0]   low_valid_is_compressed[i] = (rdata_d[i] != 2'b11);
  logic [FIFO_DEPTH-1:0]   valid_pushed[i] = (low_valid_is_compressed[i] | !err_d[i]) 
    | (in_valid_i & low_valid_is_compressed[i] & !err_q[i]);

  logic [FIFO_DEPTH-1:0]   valid_pushed[i] = (low_valid_is_compressed[i] | !err_d[i]) 
    | (in_valid_i & low_valid_is_compressed[i] & !err_q[i]);

  logic [FIFO_DEPTH-1:0]   entry_en[i] = (valid_pushed[i+1] & pop_friendly_entry[i]) 
    | (in_valid_i & err_q[i] & (~valid_q[i] | ~unaligned_is_compressed));

  logic [FIFO_DEPTH-1:0]   entry_en[i] = (valid_pushed[i+1] & pop_friendly_entry[i]) 
    | (in_valid_i & err_q[i] & (~valid_q[i] | ~unaligned_is_compressed));

  logic [FIFO_DEPTH-1:0]   valid_pushed[i] = pop_friendly_entry[i] | entry_en[i];
  logic [FIFO_DEPTH-1:0]   valid_pushed[i] = pop_friendly_entry[i] | entry_en[i];

  logic [FIFO_DEPTH-1:0]   valid_pushed[FIFO_DEPTH-1] = 1'b0;
  logic [FIFO_DEPTH-1:0]   valid_pushed[FIFO_DEPTH-1] = 1'b0;

  logic [FIFO_DEPTH-1:0]   lowest_free_entry[i] = ~valid_q[i] & low_valid_is_compressed[i];
  logic [FIFO_DEPTH-1:0]   lowest_free_entry[i] = ~valid_q[i] & low_valid_is_compressed[i];
  logic [FIFO_DEPTH-1:0]   valid_pushed[FIFO_DEPTH-1] = 1'b0;
  logic [FIFO_DEPTH-1:0]   valid_pushed[FIFO_DEPTH-1] = 1'b0;

  logic [FIFO_DEPTH-1:0]   valid_q <= valid_d;
  logic [FIFO_DEPTH-1:0]   rdata_d[i]      = rdata[i];
  logic [FIFO_DEPTH-1:0]   err_d[i]        = err_d[i];
  logic [FIFO_DEPTH-1:0]   err_d[i]        = err_d[i];

  logic [FIFO_DEPTH-1:0]   valid_q <= valid_d;
  logic [FIFO_DEPTH-1:0]   rdata_d[i]      = rdata[i];
  logic [FIFO_DEPTH-1:0]   err_d[i]        = err_d[i];
  logic [FIFO_DEPTH-1:0]   err_d[i]        = err_d[i];

  always @(*) begin
    if (rst_i) {
      clear_v[FIFO_DEPTH-1:FIFO_DEPTH-1] = 1'b1;
    }
    valid_q <= valid_d;
  end

  always @posedge clk_i or negedge rst_i) begin
    if (!rst_i) begin
      if (!clear_i) begin
        out_rdata_o     = rdata_u;
        out_err_o       = err_u;
        out_err_plus2_o = 1'b0;
      end else begin
        out_rdata_o     = rdata;
        out_err_o       = err;
        out_err_plus2_o = 1'b0;
      end
    end else begin
      out_rdata_o     = rdata_u     :   in_rdata_i[31:0],
                                rdata_u     :   in_rdata_i[31:0];
      out_err_o       = err_u       :   in_err_i   ,
                                in_err_i   :   in_err_i;
      out_err_plus2_o = 1'b0      :   in_err_i   ,
                                in_err_i   :   in_err_i;
    end
  end

  for (genvar i = 0; i < (FIFO_DEPTH - 1); i++) begin : g Instantiate
    if (ResetAll) begin : g Instantiate
      always_ff @(posedge clk_i or negedge rst_i) begin
        lowest_free_entry[i] = ~valid_q[i];
      end else begin
        lowest_free_entry[i] = 1'b1;
      end
    end else begin : g Instantiate
      always_ff @(posedge clk_i) begin
        lowest_free_entry[i] = ~valid_q[i];
      end
    end
  end
endmodule