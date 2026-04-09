module ttc_counter_lite (
    input clk,
    input reset,
    input axi_addr[3:0],
    input axi_wdata[31:0],
    input axi_write_en,
    input axi_read_en,
    output axi_rdata[31:0],
    output interrupt
);

reg [31:0] count;
reg [31:0] match_value;
reg [31:0] reload_value;
reg [31:0] control;
reg [31:0] status;

// Internal state machine
state_machine state {
    state idle;
    state counting;
    state matching;
    state reload;
} state curr_state;

initial begin
    curr_state = idle;
    count = 0;
    match_value = 0;
    reload_value = 0;
    control = 3'b000;
    status = 3'b0000;
    interrupt = 0;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        curr_state = idle;
        count = 0;
        match_value = 0;
        reload_value = 0;
        control = 3'b000;
        status = 3'b0000;
    end else begin
        if (curr_state == idle) begin
            curr_state = counting;
        end else if (curr_state == counting) begin
            if (!rel_done) begin
                count <= count + 1;
            end else begin
                curr_state = matching;
            end
        end else if (curr_state == matching) begin
            if (match_flag) begin
                curr_state = reload;
            end
        end else if (curr_state == reload) begin
            reload_value = axi_reload_value;
            curr_state = counting;
        end
    end
end

always @(*) begin
    axi_rdata = count;
    axi_rdata = match_value;
    axi_rdata = reload_value;
    axi_rdata = control;
    axi_rdata = status;
end

always @(posedge axi_write_en or negedge axi_write_en_prev) begin
    if (axi_write_en && axi_write_en_prev == 0) begin
        axi_wdata = axi_wdata;
        axi_write_en = axi_write_en_new;
        axi_read_en = axi_read_en_new;
        control = axi_control;
        match_value = axi_match;
        reload_value = axi_reload;
    end
end

always @(posedge axi_read_en or negedge axi_read_en_prev) begin
    if (axi_read_en && axi_read_en_prev == 0) begin
        axi_rdata = count;
        axi_rdata = match_value;
        axi_rdata = reload_value;
        axi_rdata = control;
        axi_rdata = status;
    end
end

always @(posedge clk or negedge reset) begin
    if (reset) begin
        interrupt = 0;
    end else if (curr_state == matching) begin
        interrupt = 1;
    end else begin
        interrupt = 0;
    end
end

always @(posedge clk or negedge reset) begin
    if (reset) begin
        curr_state = idle;
        count = 0;
        match_value = 0;
        reload_value = 0;
        control = 3'b000;
        status = 3'b0000;
        interrupt = 0;
    end
end

endmodule
