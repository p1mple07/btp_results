module queue (
    input clk_i,
    input rst_ni,
    input clr_i,
    input ena_i,
    input we_i,
    input d_i,
    input re_i,
    input q_o,
    output q_r,
    output empty_o,
    output full_o,
    output almost_empty_o,
    output almost_full_o,
    parameter int DEPTH = 8,
    parameter int DBITS = 8
);

    localvar int queue_wadr;

    initial begin
        queue_wadr = 0;
    end

    always_comb begin
        if (!rst_ni) begin
            queue_wadr = 0;
            empty_o = 1;
            full_o = 0;
            almost_empty_o = 0;
            almost_full_o = 0;
        end else
        begin
            empty_o = (queue_wadr == 0);
            full_o = (queue_wadr == MAX_Q - 1);
            almost_empty_o = (queue_wadr == 0);
            almost_full_o = (queue_wadr == MAX_Q - 1);
        end
    end

    reg [DBITS-1:0] queue_data [0:MAX_Q-1];

    always_ff @(posedge clk_i) begin
        if (ena_i && !we_i && !re_i) begin
            queue_data[0] <= queue_data[1];
        end else if (re_i) begin
            queue_data[0] = q_o;
            for (int i = 0; i < DBITS-1; i++)
                queue_data[i+1] <= queue_data[i];
            queue_wadr <= 0;
        end else if (we_i) begin
            queue_wadr = 0;
            queue_data[0] = d_i;
        end else begin
            queue_data[0] = q_o;
            for (int i = 0; i < DBITS-1; i++)
                queue_data[i+1] <= queue_data[i];
            queue_wadr = 0;
        end
    end

    assign q_r = queue_data[0];

    assign empty_o = (queue_wadr == 0);
    assign full_o = (queue_wadr == MAX_Q - 1);

    assign almost_empty_o = (queue_wadr == 0);
    assign almost_full_o = (queue_wadr == MAX_Q - 1);

endmodule
