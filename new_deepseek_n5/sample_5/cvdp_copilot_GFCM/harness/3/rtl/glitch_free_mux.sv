module glitch_free_mux
(
    input clock1,		//input clock1
    input clock2,		// input clock2
    input rst_n,	// async reset
    input sel,		// selection line
    output  clockout	// clock output
);

reg clockout_reg;
reg clock1_enable, clock2_enable;
reg clock1_out, clock2_out;

// DFlipFlop for clock domain crossings
DFlipFlop dclk1_enable(clk1_enable, clock1, ~sel);
DFlipFlop dclk2_enable(clk2_enable, clock2, sel);
DFlipFlop dclk1(clk1_out, clock1, ~sel);
DFlipFlop dclk2(clk2_out, clock2, sel);

// State machine for sel transitions
reg sel_state = 0;

always@posedge clock1 or posedge clock2 or negedge rst_n) begin
    if (~rst_n) begin
        sel_state = 0;
        clock1_enable <= 0;
        clock2_enable <= 0;
    else begin
        case(sel_state)
            0: 
                if(sel == 0)
                    sel_state = 1;
                else
                    sel_state = 0;
            1: 
                if(sel == 1)
                    sel_state = 2;
                else
                    sel_state = 1;
            2: 
                if(sel == 0)
                    sel_state = 1;
                else
                    sel_state = 2;
        endcase
    end
end

// Enable logic
always@posedge clock1 or posedge clock2 or negedge rst_n) begin
    if (~rst_n) begin
        dclk1_enable <= 0;
        dclk2_enable <= 0;
    else begin
        if(sel_state == 1 && sel == 0) begin
            dclk1_enable <= 1;
        end else if(sel_state == 1 && sel == 1) begin
            dclk2_enable <= 1;
        end else if(sel_state == 2 && sel == 0) begin
            dclk2_enable <= 1;
        end else if(sel_state == 2 && sel == 1) begin
            dclk1_enable <= 1;
        end
    end
end

// Output logic
assign clockout = (clock1 & clock1_enable) | (clock2 & clock2_enable);
endmodule