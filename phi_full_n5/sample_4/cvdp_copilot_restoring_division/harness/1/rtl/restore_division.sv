module restoring_division #(parameter WIDTH = 6)
(
    input clk,
    input rst_n,
    input start,
    input [WIDTH-1:0] dividend,
    input [WIDTH-1:0] divisor,
    output reg [WIDTH-1:0] quotient,
    output reg [WIDTH-1:0] remainder,
    output valid
);

    // Internal variables
    reg [WIDTH-1:0] temp_remainder = 0;
    reg [WIDTH-1:0] temp_quotient = 0;
    reg [WIDTH-1:0] shift_reg;
    reg [WIDTH-1:0] subtraction_result;

    // State variable for control logic
    reg [2:0] state = 0;
    reg [WIDTH-1:0] iteration_count = 0;

    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            temp_remainder <= 0;
            temp_quotient <= 0;
            iteration_count <= 0;
        end else begin
            case (state)
                3: begin
                    temp_remainder <= shift_reg;
                    temp_quotient <= temp_quotient << 1;
                    iteration_count <= iteration_count + 1;
                    if (iteration_count >= WIDTH) begin
                        state <= 0;
                        valid <= 1;
                    end else begin
                        state <= 4;
                    end
                end
                4: begin
                    shift_reg <= temp_remainder << 1;
                    shift_reg(WIDTH-1) <= dividend(WIDTH-1);
                    subtraction_result <= shift_reg - divisor;
                    if (subtraction_result(WIDTH-1) == 0) begin
                        temp_quotient <= temp_quotient + 1;
                        temp_remainder <= shift_reg;
                    end else begin
                        temp_remainder <= shift_reg >> 1;
                        temp_quotient <= temp_quotient;
                    end
                    state <= 5;
                end
                5: begin
                    if (valid) begin
                        quotient <= temp_quotient;
                        remainder <= temp_remainder;
                        valid <= 0;
                        state <= 0;
                    end
                end
                default: state <= 0;
            endcase
        end
    end

    always @(posedge start) begin
        if (start) begin
            iteration_count <= 0;
            state <= 3;
        end
    end

endmodule
 module restoring_division #(parameter WIDTH = 6)
(
    input clk,
    input rst_n,
    input start,
    input [WIDTH-1:0] dividend,
    input [WIDTH-1:0] divisor,
    output reg [WIDTH-1:0] quotient,
    output reg [WIDTH-1:0] remainder,
    output valid
);

    // Internal variables
    reg [WIDTH-1:0] temp_remainder = 0;
    reg [WIDTH-1:0] temp_quotient = 0;
    reg [WIDTH-1:0] shift_reg;
    reg [WIDTH-1:0] subtraction_result;

    // State variable for control logic
    reg [2:0] state = 0;
    reg [WIDTH-1:0] iteration_count = 0;

    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            temp_remainder <= 0;
            temp_quotient <= 0;
            iteration_count <= 0;
        end else begin
            case (state)
                3: begin
                    temp_remainder <= shift_reg;
                    temp_quotient <= temp_quotient << 1;
                    iteration_count <= iteration_count + 1;
                    if (iteration_count >= WIDTH) begin
                        state <= 0;
                        valid <= 1;
                    end else begin
                        state <= 4;
                    end
                end
                4: begin
                    shift_reg <= temp_remainder << 1;
                    shift_reg(WIDTH-1) <= dividend(WIDTH-1);
                    subtraction_result <= shift_reg - divisor;
                    if (subtraction_result(WIDTH-1) == 0) begin
                        temp_quotient <= temp_quotient + 1;
                        temp_remainder <= shift_reg;
                    end else begin
                        temp_remainder <= shift_reg >> 1;
                        temp_quotient <= temp_quotient;
                    end
                    state <= 5;
                end
                5: begin
                    if (valid) begin
                        quotient <= temp_quotient;
                        remainder <= temp_remainder;
                        valid <= 0;
                        state <= 0;
                    end
                end
                default: state <= 0;
            endcase
        end
    end

    always @(posedge start) begin
        if (start) begin
            iteration_count <= 0;
            state <= 3;
        end
    end

endmodule