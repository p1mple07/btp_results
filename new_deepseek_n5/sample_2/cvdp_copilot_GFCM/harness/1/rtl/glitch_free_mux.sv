// glitch_free_mux.sv

output reg [31:0] clkout;

always posedge(clk1) begin
    if (sel == 0) begin
        posedge(clk1);
        assign clk1_en = 1;
        assign clk2_en = 0;
    else
        posedge(clk2);
        assign clk1_en = 0;
        assign clk2_en = 1;
    end
end

always posedge(clk1_en) begin
    if (rst_n) begin
        // Reset output
        // Assign the other clock when sel changes
        if (sel == 0) begin
            assign clkout = 0;
        else
            assign clkout = 0;
        end
    end else
        // Transition smoothly to the new clock
        flip_flop_input = 1;
    end
end

always posedge(clk2_en) begin
    if (rst_n) begin
        // Reset output
        // Assign the other clock when sel changes
        if (sel == 1) begin
            assign clkout = 0;
        else
            assign clkout = 0;
        end
    end else
        // Transition smoothly to the new clock
        flip_flop_input = 0;
    end
end

// D flip-flop for glitch-free transition
flip_flop_input = 0;
flip_flop_input = flip_flop_input ^ (sel == 0 ? 1 : 0);

// Final assignment
clkout = flip_flop_input;