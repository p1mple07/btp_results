module thermostat (
    input  wire         i_clk,    // Clock for sequential logic
    input  wire         i_rst,    // Asynchronous active-low reset
    input  wire [5:0]   i_temp_feedback, // Temperature feedback bits:
                                        // bit5: i_full_cold, bit4: i_medium_cold,
                                        // bit3: i_low_cold, bit2: i_low_hot,
                                        // bit1: i_medium_hot, bit0: i_full_hot
    input  wire         i_fan_on, // Manual fan override (1 = on)
    input  wire         i_enable, // Enable thermostat (0 = off)
    input  wire         i_fault,  // Fault condition (1 = fault)
    input  wire         i_clr,    // Clear fault condition
    output reg          o_heater_full,
    output reg          o_heater_medium,
    output reg          o_heater_low,
    output reg          o_aircon_full,
    output reg          o_aircon_medium,
    output reg          o_aircon_low,
    output reg          o_fan,
    output reg [2:0]    o_state   // Current FSM state
);

   // State Encoding
   localparam HEAT_LOW   = 3'b000;
   localparam HEAT_MED   = 3'b001;
   localparam HEAT_FULL  = 3'b010;
   localparam AMBIENT    = 3'b011;
   localparam COOL_LOW   = 3'b100;
   localparam COOL_MED   = 3'b101;
   localparam COOL_FULL  = 3'b110;

   // Next state logic (combinational)
   // Priority: Cold conditions (if any cold bit is asserted) then Hot conditions, else AMBIENT.
   // Also, if fault, disable, or clear is active, force next state to AMBIENT.
   reg [2:0] next_state;
   always @(*) begin
      if (i_fault || !i_enable || i_clr)
         next_state = AMBIENT;
      else begin
         // Default to AMBIENT
         next_state = AMBIENT;
         if (i_temp_feedback[5])   // i_full_cold
            next_state = HEAT_FULL;
         else if (i_temp_feedback[4]) // i_medium_cold
            next_state = HEAT_MED;
         else if (i_temp_feedback[3]) // i_low_cold
            next_state = HEAT_LOW;
         else if (i_temp_feedback[0]) // i_full_hot
            next_state = COOL_FULL;
         else if (i_temp_feedback[1]) // i_medium_hot
            next_state = COOL_MED;
         else if (i_temp_feedback[2]) // i_low_hot
            next_state = COOL_LOW;
      end
   end

   // Sequential state register and output logic
   always @(posedge i_clk or negedge i_rst) begin
      if (!i_rst) begin
         // Asynchronous reset: Force state to AMBIENT and all outputs to 0
         o_state          <= AMBIENT;
         o_heater_full    <= 1'b0;
         o_heater_medium  <= 1'b0;
         o_heater_low     <= 1'b0;
         o_aircon_full    <= 1'b0;
         o_aircon_medium  <= 1'b0;
         o_aircon_low     <= 1'b0;
         o_fan            <= 1'b0;
      end
      else begin
         // Fault, disable, or clear override: Force outputs off and state to AMBIENT
         if (i_fault || !i_enable || i_clr) begin
            o_state          <= AMBIENT;
            o_heater_full    <= 1'b0;
            o_heater_medium  <= 1'b0;
            o_heater_low     <= 1'b0;
            o_aircon_full    <= 1'b0;
            o_aircon_medium  <= 1'b0;
            o_aircon_low     <= 1'b0;
            o_fan            <= 1'b0;
         end
         else begin
            // Normal operation: Update state and outputs based on temperature feedback
            o_state <= next_state;
            case (o_state)
               HEAT_FULL: begin
                  o_heater_full    <= 1'b1;
                  o_heater_medium  <= 1'b0;
                  o_heater_low     <= 1'b0;
                  o_aircon_full    <= 1'b0;
                  o_aircon_medium  <= 1'b0;
                  o_aircon_low     <= 1'b0;
               end
               HEAT_MED: begin
                  o_heater_full    <= 1'b0;
                  o_heater_medium  <= 1'b1;
                  o_heater_low     <= 1'b0;
                  o_aircon_full    <= 1'b0;
                  o_aircon_medium  <= 1'b0;
                  o_aircon_low     <= 1'b0;
               end
               HEAT_LOW: begin
                  o_heater_full    <= 1'b0;
                  o_heater_medium  <= 1'b0;
                  o_heater_low     <= 1'b1;
                  o_aircon_full    <= 1'b0;
                  o_aircon_medium  <= 1'b0;
                  o_aircon_low     <= 1'b0;
               end
               COOL_FULL: begin
                  o_heater_full    <= 1'b0;
                  o_heater_medium  <= 1'b0;
                  o_heater_low     <= 1'b0;
                  o_aircon_full    <= 1'b1;
                  o_aircon_medium  <= 1'b0;
                  o_aircon_low     <= 1'b0;
               end
               COOL_MED: begin
                  o_heater_full    <= 1'b0;
                  o_heater_medium  <= 1'b0;
                  o_heater_low     <= 1'b0;
                  o_aircon_full    <= 1'b0;
                  o_aircon_medium  <= 1'b1;
                  o_aircon_low     <= 1'b0;
               end
               COOL_LOW: begin
                  o_heater_full    <= 1'b0;
                  o_heater_medium  <= 1'b0;
                  o_heater_low     <= 1'b0;
                  o_aircon_full    <= 1'b0;
                  o_aircon_medium  <= 1'b0;
                  o_aircon_low     <= 1'b1;
               end
               AMBIENT: begin
                  o_heater_full    <= 1'b0;
                  o_heater_medium  <= 1'b0;
                  o_heater_low     <= 1'b0;
                  o_aircon_full    <= 1'b0;
                  o_aircon_medium  <= 1'b0;
                  o_aircon_low     <= 1'b0;
               end
               default: begin
                  o_heater_full    <= 1'b0;
                  o_heater_medium  <= 1'b0;
                  o_heater_low     <= 1'b0;
                  o_aircon_full    <= 1'b0;
                  o_aircon_medium  <= 1'b0;
                  o_aircon_low     <= 1'b0;
               end
            endcase

            // Fan control: o_fan is 1 if any heating/cooling output is active OR if i_fan_on is asserted.
            if (o_state == HEAT_FULL || o_state == HEAT_MED || o_state == HEAT_LOW ||
                o_state == COOL_FULL || o_state == COOL_MED || o_state == COOL_LOW)
               o_fan <= 1'b1;
            else
               o_fan <= i_fan_on;
         end
      end
   end

endmodule