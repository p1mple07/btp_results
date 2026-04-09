module glitch_free_mux
(
    input clk1,		//input clk1
    input clk2,		// input clk2
    input rst_n,	// async reset
    input sel,		// selection line
    output  clkout	// clock output
);

reg sel_prev;		// To track previous sel value
reg enable1, enable2;	// Enable states for each clock
reg counter1, counter2;	// Counters for clock domains

// Initialize sel_prev to 0
initial sel_prev = 0;

// CLK1 ENABLE LOGIC
always@posedge(clk1 or rst_n) begin
    if (~rst_n) begin
        enable1 = 0;
        counter1 = 0;
    end else begin
        enable1 = ~sel & (counter1 == 1);
        counter1 = counter1 + 1;
        if (counter1 >= 2) begin
            enable1 = 0;
            counter1 = 0;
        end
    end
end

// CLK2 ENABLE LOGIC
always@posedge(clk2 or rst_n) begin
    if (~rst_n) begin
        enable2 = 0;
        counter2 = 0;
    end else begin
        enable2 = ~sel & (counter2 == 1);
        counter2 = counter2 + 1;
        if (counter2 >= 2) begin
            enable2 = 0;
            counter2 = 0;
        end
    end
end

// Output logic
assign clkout = (clk1 & enable1) | (clk2 & enable2);

// Additional sel logic
always @posedge(clk1 or sel or sel_prev) begin
    if (sel != sel_prev) begin
        sel_prev = sel;
        if (sel == 1) begin
            enable1 = 0;
            counter1 = 0;
        else begin
            enable2 = 0;
            counter2 = 0;
        end
    end
end