// Parameters
parameter CLK_FREQ = 100_000_000;
parameter BIT_RATE = 115200;
parameter BIT_PER_WORD = 8;
parameter PARITY_BIT = 0;
parameter STOP_BITS_NUM = 1;

// Variables
 reg  clk_counter; // Number of clock cycles counted
 reg bit_counter;  // Number of bits transmitted
 reg state;        // Current state of the FSM
 reg tx;           // UART output register
 reg parity_bit;  // Computed parity bit

// FSM states
 enum fsm_state {
  IDLE,
  START,
  DATA,
  PARITY,
  STOP1,
  STOP2
 }

// Module implementation
always_ff @(posedge aclk or posedge areshetn) begin
   if (aresetn)
      state = IDLE;
      bit_counter = 0;
      clk_counter = 0;
      tx = 1;
      tready = 0;
      return;
   end

   // Transition logic
   case(state)
   // IDLE -> START: Check for valid data
   when(IDLE)
     if (tvalid && tready) begin
       state = START;
       bit_counter = 0;
       clk_counter = 0;
       tx = 1;
     end else 
     state = IDLE;
   endcase

   // START -> DATA: Wait for one bit period
   when(START)
     if (clk_counter == Cycle_per_Period - 1) begin
       state = DATA;
       bit_counter = 0;
     end
   endcase

   // DATA -> PARITY or STOP1: Transmit data bits
   when(DATA)
     // Shift data left (LSB first)
     data[bit_counter] = tdata & 1;
     bit_counter = bit_counter + 1;

     if (bit_counter == BIT_PER_WORD) begin
       // Complete data bits: Check if parity is needed
       if (PARITY_BIT != 0) begin
         parity_bit = parity();
         tx = parity_bit;
       end else 
       tx = 1;

       state = PARITY;
     end
   endcase

   // PARITY -> STOP1: Transmit parity bit
   when(PARITY)
     state = STOP1;
     tx = 1;
   endcase

   // STOP1 -> (IDLE or STOP2): Transmit stop bits
   when(STOP1)
     if (clk_counter == Cycle_per_Period - 1) begin
       state = (STOP_BITS_NUM == 1 ? IDLE : STOP2);
       tx = 1;
     end else 
     tx = 0;
   endcase

   // STOP2 -> IDLE: After second stop bit
   when(STOP2)
     state = IDLE;
     tx = 1;
   endcase
end