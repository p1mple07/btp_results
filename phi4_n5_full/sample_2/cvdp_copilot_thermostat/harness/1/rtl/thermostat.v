module thermostat (
    input  wire         i_clk,    // Clock
    input  wire         i_rst,    // Asynchronous active-low reset
    input  wire [5:0]   i_temp_feedback, // Temperature feedback bits:
                                        // [5] = i_full_cold, [4] = i_medium_cold,
                                        // [3] = i_low_cold, [2] = i_low_hot,
                                        // [1] = i_medium_hot, [0] = i_full_hot
    input  wire         i_fan_on, // Manual fan control (1 = on)
    input  wire         i_enable, // Enable thermostat (0 = off)
    input  wire         i_fault,  // Fault signal (1 = fault active)
    input  wire         i_clr,    // Clear fault signal (assert to return to AMBIENT)
    output reg          o_heater_full,
    output reg          o_heater_medium,
    output reg          o_heater_low,
    output reg          o_aircon_full,
    output reg          o_aircon_medium,
    output reg          o_aircon_low,
    output reg          o_fan,
    output reg [2:0]    o_state   // FSM state output
);

   // State encoding
   localparam HEAT_LOW   = 3'b000;
   localparam HEAT_MED   = 3'b001;
   localparam HEAT_FULL  = 3'b010;
   localparam AMBIENT    = 3'b011;
   localparam COOL_LOW   = 3'b100;
   localparam COOL_MED   = 3'b101;
   localparam COOL_FULL  = 3'b110;

   // State registers
   reg [2:0] state, next_state;

   //-------------------------------------------------------------------------
   // Next State Logic (combinational)
   // Evaluate temperature feedback only when no fault is active.
   // Priority: Cold conditions > Hot conditions > Ambient.
   //-------------------------------------------------------------------------
   always @(*) begin
       // Default next state: AMBIENT
       next_state = AMBIENT;
       if (!i_fault) begin
           if (i_temp_feedback[5]) begin       // i_full_cold
               next_state = HEAT_FULL;
           end else if (i_temp_feedback[4]) begin // i_medium_cold
               next_state = HEAT_MED;
           end else if (i_temp_feedback[3]) begin // i_low_cold
               next_state = HEAT_LOW;
           end else if (i_temp_feedback[0]) begin // i_full_hot
               next_state = COOL_FULL;
           end else if (i_temp_feedback[1]) begin // i_medium_hot
               next_state = COOL_MED;
           end else if (i_temp_feedback[2]) begin // i_low_hot
               next_state = COOL_LOW;
           end else begin
               next_state = AMBIENT;
           end
       end
   end

   //-------------------------------------------------------------------------
   // State Register Update
   // On each rising clock edge (when i_rst is high), update the state.
   // Priority overrides:
   //   1. Asynchronous reset (i_rst = 0) -> state = AMBIENT.
   //   2. Fault active (i_fault = 1) -> state remains unchanged.
   //   3. Disable (i_enable = 0) -> state forced to AMBIENT.
   //   4. Clear fault (i_clr asserted) -> state set to AMBIENT.
   //   5. Normal operation -> state = next_state.
   //-------------------------------------------------------------------------
   always @(posedge i_clk or negedge i_rst) begin
       if (!i_rst) begin
           state <= AMBIENT;
       end else begin
           if (i_fault) begin
               // Fault active: do not update state.
               state <= state;
           end else if (!i_enable) begin
               // Disable override: force state to AMBIENT.
               state <= AMBIENT;
           end else if (i_clr) begin
               // Clear fault: return to AMBIENT on next clock edge.
               state <= AMBIENT;
           end else begin
               state <= next_state;
           end
       end
   end

   //-------------------------------------------------------------------------
   // Output Logic
   // Outputs are synchronous to i_clk and are asynchronously reset.
   // Overriding conditions:
   //   - i_fault = 1: All outputs forced to 0.
   //   - i_enable = 0: All outputs forced to 0 and state internally AMBIENT.
   // Otherwise, outputs follow the FSM state:
   //   Heating states: activate corresponding heater output.
   //   Cooling states: activate corresponding aircon output.
   //   AMBIENT: all heater/aircon outputs 0.
   // Fan control: o_fan = 1 if any heater/aircon output is active OR if i_fan_on = 1.
   //-------------------------------------------------------------------------
   always @(posedge i_clk or negedge i_rst) begin
       if (!i_rst) begin
           o_heater_full    <= 1'b0;
           o_heater_medium  <= 1'b0;
           o_heater_low     <= 1'b0;
           o_aircon_full    <= 1'b0;
           o_aircon_medium  <= 1'b0;
           o_aircon_low     <= 1'b0;
           o_fan            <= 1'b0;
           o_state          <= AMBIENT;
       end else begin
           // Fault override: force all outputs to 0.
           if (i_fault) begin
               o_heater_full    <= 1'b0;
               o_heater_medium  <= 1'b0;
               o_heater_low     <= 1'b0;
               o_aircon_full    <= 1'b0;
               o_aircon_medium  <= 1'b0;
               o_aircon_low     <= 1'b0;
               o_fan            <= 1'b0;
               o_state          <= state;  // State remains but outputs are off.
           end 
           // Disable override: force outputs to 0 and state to AMBIENT.
           else if (!i_enable) begin
               o_heater_full    <= 1'b0;
               o_heater_medium  <= 1'b0;
               o_heater_low     <= 1'b0;
               o_aircon_full    <= 1'b0;
               o_aircon_medium  <= 1'b0;
               o_aircon_low     <= 1'b0;
               o_fan            <= 1'b0;
               o_state          <= AMBIENT;
           end 
           // Normal operation based on FSM state.
           else begin
               case (state)
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
               endcase

               // Fan control: Turn fan on if any heater/aircon output is active,
               // or if i_fan_on is asserted.
               if ((state == HEAT_FULL) || (state == HEAT_MED) || (state == HEAT_LOW) ||
                   (state == COOL_FULL) || (state == COOL_MED) || (state == COOL_LOW))
                   o_fan <= 1'b1;
               else
                   o_fan <= i_fan_on;
               
               o_state <= state;
           end
       end
   end

endmodule