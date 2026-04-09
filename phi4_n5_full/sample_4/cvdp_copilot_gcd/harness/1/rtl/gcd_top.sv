Module: gcd_top
//--------------------------------------------------
module gcd_top #(parameter WIDTH = 4)(
    input  logic                 clk,
    input  logic                 rst,
    input  logic [WIDTH-1:0]     A,
    input  logic [WIDTH-1:0]     B,
    input  logic                 go,
    output logic [WIDTH-1:0]     OUT,
    output logic                 done
);

  // Internal signals to connect control and datapath
  wire [1:0] control_state;
  wire       equal, greater_than;

  // Instantiate the GCD Control Path Module
  gcd_controlpath #(.WIDTH(WIDTH)) u_gcd_controlpath (
      .clk               (clk),
      .rst               (rst),
      .go                (go),
      .equal             (equal),
      .greater_than      (greater_than),
      .controlpath_state (control_state),
      .done              (done)
  );

  // Instantiate the GCD Datapath Module
  gcd_datapath #(.WIDTH(WIDTH)) u_gcd_datapath (
      .clk                (clk),
      .rst                (rst),
      .A                  (A),
      .B                  (B),
      .controlpath_state  (control_state),
      .OUT                (OUT),
      .equal              (equal),
      .greater_than       (greater_than)
  );

endmodule
//--------------------------------------------------
// Module: gcd_controlpath
//--------------------------------------------------
module gcd_controlpath #(parameter WIDTH = 4)(
    input  logic         clk,
    input  logic         rst,
    input  logic         go,
    input  logic         equal,
    input  logic         greater_than,
    output logic [1:0]   controlpath_state,
    output logic         done
);

  // Define FSM states:
  // S0: IDLE, S1: DONE, S2: A > B, S3: B > A
  localparam S0 = 2'b00,
             S1 = 2'b01,
             S2 = 2'b10,
             S3 = 2'b11;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      controlpath_state <= S0;
    end
    else begin
      case (controlpath_state)
        S0: begin
          if (go) begin
            if (equal)
              controlpath_state <= S1;  // Computation complete
            else if (greater_than)
              controlpath_state <= S2;  // Subtract B from A
            else
              controlpath_state <= S3;  // Subtract A from B
          end
          // Remain in S0 if go is not asserted
        end
        S1: begin
          // After asserting done, return to IDLE for a new computation
          controlpath_state <= S0;
        end
        S2: begin
          // After performing subtraction, return to IDLE to recheck condition
          controlpath_state <= S0;
        end
        S3: begin
          // After performing subtraction, return to IDLE to recheck condition
          controlpath_state <= S0;
        end
        default: controlpath_state <= S0;
      endcase
    end
  end

  // The done signal is asserted in state S1 (computation complete)
  assign done = (controlpath_state == S1);

endmodule
//--------------------------------------------------
// Module: gcd_datapath
//--------------------------------------------------
module gcd_datapath #(parameter WIDTH = 4)(
    input  logic         clk,
    input  logic         rst,
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic [1:0]   controlpath_state,
    output logic [WIDTH-1:0] OUT,
    output logic         equal,
    output logic         greater_than
);

  // Internal registers to hold intermediate values of A and B
  logic [WIDTH-1:0] A_ff, B_ff;

  // Sequential block: Latch new inputs or perform subtraction based on FSM state
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      A_ff <= '0;
      B_ff <= '0;
      OUT  <= '0;
    end
    else begin
      case (controlpath_state)
        2'b00: begin
          // S0: IDLE - latch new A and B values for a new computation
          A_ff <= A;
          B_ff <= B;
          // OUT is not updated in S0
        end
        2'b10: begin
          // S2: A > B - subtract B_ff from A_ff
          A_ff <= A_ff - B_ff;
        end
        2'b11: begin
          // S3: B > A - subtract A_ff from B_ff
          B_ff <= B_ff - A_ff;
        end
        default: ; // No operation for undefined states
      endcase

      // When computation is complete (FSM in S1), update OUT with the GCD result.
      // Note: In S1, equal is asserted so A_ff == B_ff.
      if (controlpath_state == 2'b01)
        OUT <= A_ff;
    end
  end

  // Combinational logic to generate equal and greater_than signals:
  // In S0, compare the new inputs A and B; otherwise, compare the latched values.
  assign equal    = (controlpath_state == 2'b00) ? (A == B) : (A_ff == B_ff);
  assign greater_than = (controlpath_state == 2'b00) ? (A > B) : (A_ff > B_ff);

endmodule