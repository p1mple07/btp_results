module radix2_div(
    input            clk,
    input            rst_n,
    input            start,
    input      [7:0] dividend,
    input      [7:0] divisor,
    output reg [7:0] quotient,
    output reg [7:0] remainder,
    output reg       done
);

    reg [7:0] rem;
    reg [3:0] bit_counter;
    reg [7:0] divisor_reg;
    reg       busy;

    // Normal, correct shift and compare logic
    wire [8:0] shifted_rem = {rem, dividend[bit_counter]};
    wire       bit_set     = shifted_rem >= {1'b0, divisor_reg};
    wire [8:0] next_rem    = bit_set? (shifted_rem - {1'b0, divisor_reg}) : shifted_rem;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            quotient <= 8'd0;
            remainder <= 8'd0;
        end
        else if (start &&!busy) begin
            if (divisor == 8'd0) begin
                quotient <= 8'hFF;
                remainder <= 8'hFF;
            end
            else begin
                quotient <= 8'd0;
                remainder <= 8'd0;
            end
        end
        else if (busy) begin
            quotient[bit_counter] <= bit_set;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rem <= 8'd0;
        end
        else if (start &&!busy) begin
            rem <= 8'd0;
        end
        else if (busy) begin
            rem <= next_rem[7:0];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_counter <= 4'd0;
        end
        else if (start &&!busy) begin
            if (divisor!= 8'd0) begin
                bit_counter <= 4'd7;  // Start from LSB
            end
        end
        else if (busy && bit_counter!= 4'd0) begin
            bit_counter <= bit_counter - 4'd1; // Normal decrement
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            divisor_reg <= 8'd0;
        end
        else if (start &&!busy && divisor!= 8'd0) begin
            divisor_reg <= divisor;
        end
        else if (busy && bit_counter == 4'd0) begin
            divisor_reg <= divisor;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done <= 1'b0;
        end
        else if (start &&!busy) begin
            if (divisor == 8'd0) begin
                done <= 1'b1;
            end
            else begin
                done <= 1'b0;
            end
        end
        else if (busy && bit_counter == 4'd0) begin
            done <= 1'b0;
        end
        else if (busy && bit_counter == 4'd0) begin
            done <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy <= 1'b0;
        end
        else if (start &&!busy) begin
            busy <= 1'b1;
        end
        else if (busy && bit_counter == 4'd0) begin
            busy <= 1'b0;
        end
        else begin
            busy <= 1'b0;
        end
    end

endmodule