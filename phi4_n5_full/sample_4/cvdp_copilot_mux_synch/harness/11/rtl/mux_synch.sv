module mux_synch (
  input  [7:0] data_in,    // asynchronous data input
  input        req,        // indicating that data is available at the data_in input
  input        dst_clk,    // destination clock
  input        src_clk,    // source clock
  input        nrst,       // asynchronous active-low reset
  output reg [7:0] data_out, // synchronized version of data_in to the destination clock domain
  output       ack_out     // acknowledgment signal sent back to the source clock domain
);

  wire syncd_req, anded_req, syncd_ack;
  reg  syncd_req_1;
  // Instead of a one-cycle pulse, we generate a two-cycle pulse for ack
  reg [1:0] ack_counter;

  // Two-flop synchronizer for req signal crossing to destination clock domain
  nff req_synch_0 (
    .d_in(req),
    .dst_clk(dst_clk),
    .rst(nrst),
    .syncd(syncd_req)
  );

  // Delay the synchronized req signal by one clock cycle to detect its rising edge
  always_ff @(posedge dst_clk) begin
    syncd_req_1 <= syncd_req;
  end

  // Rising edge detection on the req signal
  assign anded_req = (!syncd_req_1 && syncd_req);

  // Capture the data on the rising edge of the synchronized req pulse
  always_ff @(posedge dst_clk or negedge nrst) begin
    if (!nrst)
      data_out <= 8'b0;
    else if (anded_req)
      data_out <= data_in;
    // else: hold data_out
  end

  // Generate a two-cycle acknowledgment pulse.
  // This ensures that even if the pulse does not coincide with a source clock edge,
  // it will be long enough to be reliably sampled by the synchronizer.
  always_ff @(posedge dst_clk or negedge nrst) begin
    if (!nrst)
      ack_counter <= 2'b00;
    else if (anded_req)
      ack_counter <= 2'b01; // start the pulse
    else if (ack_counter != 2'b00)
      ack_counter <= ack_counter + 1; // extend the pulse for one more cycle
    else
      ack_counter <= 2'b00;
  end

  // Drive the ack signal based on the counter
  assign ack = (ack_counter != 2'b00);

  // Synchronize the extended ack pulse from destination clock domain to source clock domain
  nff enable_synch_1 (
    .d_in(ack),
    .dst_clk(src_clk),
    .rst(nrst),
    .syncd(syncd_ack)
  );

  assign ack_out = syncd_ack;

endmodule

module nff (
  input  d_in,          // data that needs to be synchronized
  input  dst_clk,       // destination clock
  input  rst,           // asynchronous active-low reset
  output reg syncd      // synchronized output (2 clock-cycle delayed version of d_in)
);
  reg dmeta;             // intermediate register

  always @(posedge dst_clk or negedge rst) begin
    if (!rst) begin
      syncd  <= 1'b0;
      dmeta  <= 1'b0;
    end else begin
      dmeta  <= d_in;
      syncd  <= dmeta;
    end
  end

endmodule