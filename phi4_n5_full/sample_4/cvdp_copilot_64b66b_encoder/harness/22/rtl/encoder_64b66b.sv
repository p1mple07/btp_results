module encoder_64b66b (
    input  logic         clk_in,              
    input  logic         rst_in,              
    input  logic [63:0]  encoder_data_in,     
    input  logic [7:0]   encoder_control_in,  
    output logic [65:0]  encoder_data_out     
);

    // Internal signals
    logic [1:0]  sync_word;
    logic [63:0] encoded_data;

    //-------------------------------------------------------------------------
    // Synchronize sync_word using a single ternary operator.
    // When reset, sync_word is 2'b00; otherwise, if encoder_control_in is 0,
    // sync_word becomes 2'b01, else 2'b10.
    //-------------------------------------------------------------------------
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in)
            sync_word <= 2'b00;
        else
            sync_word <= (encoder_control_in == 8'b0) ? 2'b01 : 2'b10;
    end

    //-------------------------------------------------------------------------
    // Synchronize encoded_data using a ternary operator.
    // When reset, encoded_data is 0; otherwise, if encoder_control_in is 0,
    // encoded_data follows encoder_data_in; else it is forced to 0.
    //-------------------------------------------------------------------------
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in)
            encoded_data <= 64'b0;
        else
            encoded_data <= (encoder_control_in == 8'b0) ? encoder_data_in : 64'b0;
    end

    //-------------------------------------------------------------------------
    // Optimized get_output function.
    // Replaces the long if/else chain with a case statement on the control input.
    // This structure minimizes LUT usage while preserving the original encoding.
    //-------------------------------------------------------------------------
    function [7:0] get_output(input [63:0] data_in, input [7:0] control_input);
        case (control_input)
            8'hFF: begin  // 11111111
                case (data_in)
                    64'h0707070707070707: get_output = 8'h1e;
                    64'hFEFEFEFEFEFEFEFE: get_output = 8'h1e;
                    64'h07070707070707FD: get_output = 8'h87;
                    default:              get_output = 8'h0;
                endcase
            end
            8'h1F: begin  // 00011111
                if (data_in[39:0] == 40'hFB07070707)
                    get_output = 8'h33;
                else if (data_in[39:0] == 40'h9C07070707)
                    get_output = 8'h2d;
                else
                    get_output = 8'h0;
            end
            8'h01: begin  // 00000001
                get_output = (data_in[7:0] == 8'hFB) ? 8'h78 : 8'h0;
            end
            8'hFE: begin  // 11111110
                get_output = (data_in[63:8] == 56'h070707070707FD) ? 8'h99 : 8'h0;
            end
            8'hFC: begin  // 11111100
                get_output = (data_in[63:16] == 48'h0707070707FD) ? 8'haa : 8'h0;
            end
            8'hF8: begin  // 11111000
                get_output = (data_in[63:24] == 40'h07070707FD) ? 8'hb4 : 8'h0;
            end
            8'hF0: begin  // 11110000
                get_output = (data_in[63:32] == 32'h070707FD) ? 8'hcc : 8'h0;
            end
            8'hE0: begin  // 11100000
                get_output = (data_in[63:40] == 24'h0707FD) ? 8'hd2 : 8'h0;
            end
            8'hC0: begin  // 11000000
                get_output = (data_in[63:48] == 16'h07FD) ? 8'he1 : 8'h0;
            end
            8'h80: begin  // 10000000
                get_output = (data_in[63:56] == 8'hFD) ? 8'hff : 8'h0;
            end
            8'hF9: begin  // 11110001
                get_output = (({data_in[63:32], data_in[7:0]} == 40'h070707079C)) ? 8'h4b : 8'h0;
            end
            8'h11: begin  // 00010001
                if ({data_in[39:32], data_in[7:0]} == 16'h9C9C)
                    get_output = 8'h55;
                else if ({data_in[39:32], data_in[7:0]} == 16'hFB9C)
                    get_output = 8'h66;
                else
                    get_output = 8'h0;
            end
            default: 
                get_output = 8'h0;
        endcase
    endfunction

    //-------------------------------------------------------------------------
    // Internal signals for control word generation.
    //-------------------------------------------------------------------------
    logic [1:0]  sync_ctrl_word;
    logic [7:0]  type_field;
    logic [55:0] encoded_ctrl_words;

    //-------------------------------------------------------------------------
    // Optimize encoded_ctrl_words generation.
    // Uses a case statement on encoder_control_in to select the appropriate
    // encoding of control words. Redundant assignments have been removed.
    //-------------------------------------------------------------------------
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in)
            encoded_ctrl_words <= 56'b0;
        else begin
            case (encoder_control_in)
                8'hFF: begin  // 11111111
                    if (encoder_data_in == 64'h0707070707070707)
                        encoded_ctrl_words <= {7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00};
                    else if (encoder_data_in == 64'hFEFEFEFEFEFEFEFE)
                        encoded_ctrl_words <= {7'h1E, 7'h1E, 7'h1E, 7'h1E, 7'h1E, 7'h1E, 7'h1E, 7'h1E};
                    else if (encoder_data_in == 64'h07070707070707FD)
                        encoded_ctrl_words <= {7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00};
                    else
                        encoded_ctrl_words <= 56'b0;
                end
                8'h1F: begin  // 00011111
                    if (encoder_data_in[39:0] == 40'hFB07070707)
                        encoded_ctrl_words <= {encoder_data_in[63:40], 4'h0, 7'h00, 7'h00, 7'h00, 7'h00};
                    else if (encoder_data_in[39:0] == 40'h9C07070707)
                        encoded_ctrl_words <= {encoder_data_in[63:40], 4'hF, 7'h00, 7'h00, 7'h00, 7'h00};
                    else
                        encoded_ctrl_words <= 56'b0;
                end
                8'h01: begin  // 00000001
                    if (encoder_data_in[7:0] == 8'hFB)
                        encoded_ctrl_words <= {encoder_data_in[63:8]};
                    else
                        encoded_ctrl_words <= 56'b0;
                end
                8'hFE: begin  // 11111110
                    if (encoder_data_in[63:8] == 56'h070707070707FD)
                        encoded_ctrl_words <= {7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 6'b000000, encoder_data_in[7:0]};
                    else
                        encoded_ctrl_words <= 56'b0;
                end
                8'hFC: begin  // 11111100
                    if (encoder_data_in[63:16] == 48'h0707070707FD)
                        encoded_ctrl_words <= {7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 5'b00000, encoder_data_in[15:0]};
                    else
                        encoded_ctrl_words <= 56'b0;
                end
                8'hF8: begin  // 11111000
                    if (encoder_data_in[63:24] == 40'h07070707FD)
                        encoded_ctrl_words <= {7'h00, 7'h00, 7'h00, 7'h00, 4'b0000, encoder_data_in[23:0]};
                    else
                        encoded_ctrl_words <= 56'b0;
                end
                8'hF0: begin  // 11110000
                    if (encoder_data_in[63:32] == 32'h070707FD)
                        encoded_ctrl_words <= {7'h00, 7'h00, 7'h00, 3'b000, encoder_data_in[31:0]};
                    else
                        encoded_ctrl_words <= 56'hFFFFFFF;  // Retaining original constant
                end
                8'hE0: begin  // 11100000
                    if (encoder_data_in[63:40] == 24'h0707FD)
                        encoded_ctrl_words <= {7'h00, 7'h00, 2'b00, encoder_data_in[39:0]};
                    else
                        encoded_ctrl_words <= 56'b0;
                end
                8'hC0: begin  // 11000000
                    if (encoder_data_in[63:48] == 16'h07FD)
                        encoded_ctrl_words <= {7'h00, 1'b0, encoder_data_in[47:0]};
                    else
                        encoded_ctrl_words <= 56'b0;
                end
                8'h80: begin  // 10000000
                    if (encoder_data_in[63:56] == 8'hFD)
                        encoded_ctrl_words <= encoder_data_in[55:0];
                    else
                        encoded_ctrl_words <= 56'b0;
                end
                8'hF9: begin  // 11110001
                    if ({encoder_data_in[63:32], encoder_data_in[7:0]} == 40'h070707079C)
                        encoded_ctrl_words <= {7'h00, 7'h00, 7'h00, 7'h00, encoder_data_in[31:8], 4'b1111};
                    else
                        encoded_ctrl_words <= 56'b0;
                end
                8'h11: begin  // 00010001
                    if ({encoder_data_in[39:32], encoder_data_in[7:0]} == 16'h9C9C)
                        encoded_ctrl_words <= {encoder_data_in[63:40], 8'hFF, encoder_data_in[31:8]};
                    else if ({encoder_data_in[39:32], encoder_data_in[7:0]} == 16'hFB9C)
                        encoded_ctrl_words <= {encoder_data_in[63:40], 8'h0F, encoder_data_in[31:8]};
                    else
                        encoded_ctrl_words <= 56'd0;
                end
                default:
                    encoded_ctrl_words <= 56'd0;
            endcase
        end
    end

    //-------------------------------------------------------------------------
    // Optimize generation of sync_ctrl_word and type_field.
    // When reset, both are 0; otherwise, sync_ctrl_word is set to 2'b10
    // when encoder_control_in is non-zero, and type_field is computed
    // using the optimized get_output function.
    //-------------------------------------------------------------------------
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_ctrl_word <= 2'b00;
            type_field     <= 8'b0;
        end else begin
            sync_ctrl_word <= (encoder_control_in != 8'b0) ? 2'b10 : sync_ctrl_word;
            type_field     <= get_output(encoder_data_in, encoder_control_in);
        end
    end

    //-------------------------------------------------------------------------
    // Combinational output generation.
    // Uses a ternary operator to select between the two encoding paths,
    // ensuring one clock cycle latency.
    //-------------------------------------------------------------------------
    always_comb begin
        encoder_data_out = (|encoder_control_in) 
            ? {sync_ctrl_word, type_field, encoded_ctrl_words} 
            : {sync_word, encoded_data};
    end

endmodule