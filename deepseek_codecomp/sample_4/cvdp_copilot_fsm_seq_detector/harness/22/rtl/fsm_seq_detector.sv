////////////// RTL code for Sequence Detector //////////////////

module fsm_seq_detector
(
    input 	bit 	clk_in		,	// Free Running Clock
    input 	logic 	rst_in		,	// Active HIGH reset
    input 	logic 	seq_in		,	// Continuous 1-bit Sequence Input
    output 	logic 	seq_detected	// '0': Not Detected. '1': Detected. Will be HIGH for 1 Clock cycle Only

);

//FSM States Declaration, with S0 being reset State
  typedef enum logic [2:0] {S0, S1, S2, S3, S4, S5, S6, S7} state_t;
  state_t cur_state,next_state;
  
//Register Declaration
logic seq_detected_w;  //Wire used in combinational always block
  
 // FSM State assignment Logic
always @ (posedge clk_in or posedge rst_in)
begin
  if (rst_in)
    cur_state <= S0;
  else
    cur_state <= next_state;
end

//Combinational Always Block with FSM Logic For Detecting Sequence
  always_comb begin
    if(rst_in) begin
      seq_detected_w = 1'b0;
      next_state = S0;
    end
    else begin
      case(cur_state)
        S0: begin                   // reset or default State
          if(seq_in) begin
            next_state = S1;
            seq_detected_w = 1'b0;
          end
          else begin
            seq_detected_w = 1'b0;
            next_state = S0;
          end	
        end
        S1: begin                   //enter this state if Hit 1
          if(seq_in) begin
            next_state = S1;
            seq_detected_w = 1'b0;
          end
          else begin
            next_state = S2;
            seq_detected_w = 1'b0;
          end
        end
        S2: begin                   //enter this state if Hit 10
          if(seq_in) begin
            next_state = S3;
            seq_detected_w = 1'b0;
          end
          else begin
            next_state = S0;
            seq_detected_w = 1'b0;
          end
        end
        S3: begin                   //enter this state if Hit 101
          if(seq_in) begin
            next_state = S4;
            seq_detected_w = 1'b0;
          end
          else begin
            next_state = S2;
            seq_detected_w = 1'b0;
          end
        end
        S4: begin                   //enter this state if Hit 1011
          if(seq_in) begin
            next_state = S1;
            seq_detected_w = 1'b0;
          end
          else begin
            next_state = S5;
            seq_detected_w = 1'b0;
          end
        end
        S5: begin                  //enter this state if Hit 10110
          if(seq_in) begin
            next_state = S3;
            seq_detected_w = 1'b0;
          end
          else begin
            next_state = S6;
            seq_detected_w = 1'b0;
          end
        end
        S6: begin                 //enter this state if Hit 101100
          if(seq_in) begin
            next_state = S1;
            seq_detected_w = 1'b0;
          end
          else begin
            next_state = S7;
            seq_detected_w = 1'b0;
          end
        end
        S7: begin                //enter this state if Hit 1011000
          if(seq_in) begin
            next_state = S1;          // Overlapping case
            seq_detected_w = 1'b1;    // Output HIGH if Sequence matches with 10110001
          end
          else begin
            next_state = S0;
            seq_detected_w = 1'b0;    // Output LOW if Sequence does not match
          end
        end
        default: begin          //Default state
            next_state = S0;
            seq_detected_w = 1'b0;
          end

      endcase
    end
  end
  
  
 // Sequenctial Always Block for registering Output to Avoid Glitches
always @ (posedge clk_in or posedge rst_in)
begin
  if (rst_in)
    seq_detected <= 1'b0;
  else
    seq_detected <= seq_detected_w;
end
  

endmodule