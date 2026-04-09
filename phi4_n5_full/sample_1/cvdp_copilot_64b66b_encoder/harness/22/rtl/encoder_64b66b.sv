module encoder_64b66b (
    input  logic         clk_in,              // Clock signal
    input  logic         rst_in,              // Asynchronous reset (active high)
    input  logic [63:0]  encoder_data_in,     // 64-bit data input
    input  logic [7:0]   encoder_control_in,  // 8-bit control input
    output logic [65:0]  encoder_data_out     // 66-bit encoded output
);

    // Internal signals
    logic [1:0]  sync_word;
    logic [63:0] encoded_data;
    logic [1:0]  sync_ctrl_word;
    logic [7:0]  type_field;
    logic [55:0] encoded_ctrl_words;

    //----------------------------------------------------------------------------
    // Combined sequential block for sync_word and encoded_data
    //----------------------------------------------------------------------------
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word      <= 2'b00;
            encoded_data   <= 64'd0;
        end else begin
            if (encoder_control_in == 8'b00000000) begin
                sync_word      <= 2'b01;
                encoded_data   <= encoder_data_in;
            end else begin
                sync_word      <= 2'b10;
                encoded_data   <= 64'd0;
            end
        end
    end

    //----------------------------------------------------------------------------
    // Optimized get_output function using a case statement to reduce LUT usage
    //----------------------------------------------------------------------------
    function [7:0] get_output(input [63:0] data_in, input [7:0] ctrl);
      case (ctrl)
        8'b11111111: begin
          if (data_in == 64'h0707070707070707 ||
              data_in == 64'h07070707070707FD)
              get_output = 8'h0;
          else if (data_in == 64'hFEFEFEFEFEFEFEFE)
              get_output = 8'h1e;
          else
              get_output = 8'h0;
        end
        8'b00011111: begin
          if (data_in[39:0] == 40'hFB07070707)
              get_output = 8'h33;
          else if (data_in[39:0] == 40'h9C07070707)
              get_output = 8'h2d;
          else
              get_output = 8'h0;
        end
        8'b00000001: begin
          get_output = (data_in[7:0] == 8'hFB) ? 8'h78 : 8'h0;
        end
        8'b11111110: begin
          get_output = (data_in[63:8] == 56'h070707070707FD) ? 8'h99 : 8'h0;
        end
        8'b11111100: begin
          get_output = (data_in[63:16] == 48'h0707070707FD) ? 8'haa : 8'h0;
        end
        8'b11111000: begin
          get_output = (data_in[63:24] == 40'h07070707FD) ? 8'hb4 : 8'h0;
        end
        8'b11110000: begin
          get_output = (data_in[63:32] == 32'h070707FD) ? 8'hcc : 8'h0;
        end
        8'b11100000: begin
          get_output = (data_in[63:40] == 24'h0707FD) ? 8'hd2 : 8'h0;
        end
        8'b11000000: begin
          get_output = (data_in[63:48] == 16'h07FD) ? 8'he1 : 8'h0;
        end
        8'b10000000: begin
          get_output = (data_in[63:56] == 8'hFD) ? 8'hff : 8'h0;
        end
        8'b11110001: begin
          get_output = ({data_in[63:32], data_in[7:0]} == 40'h070707079C) ? 8'h4b : 8'h0;
        end
        8'b00010001: begin
          if ({data_in[39:32], data_in[7:0]} == 16'h9C9C)
              get_output = 8'h55;
          else if ({data_in[39:32], data_in[7:0]} == 16'hFB9C)
              get_output = 8'h66;
          else
              get_output = 8'h0;
        end
        default: get_output = 8'h0;
      endcase
    endfunction

    //----------------------------------------------------------------------------
    // Optimized sequential logic for encoded_ctrl_words using a case statement
    //----------------------------------------------------------------------------
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in)
            encoded_ctrl_words <= 56'd0;
        else
            case (encoder_control_in)
                8'b11111111: begin
                    if (encoder_data_in == 64'h0707070707070707 ||
                        encoder_data_in == 64'h07070707070707FD)
                        encoded_ctrl_words <= 56'd0;
                    else if (encoder_data_in == 64'hFEFEFEFEFEFEFEFE)
                        encoded_ctrl_words <= {7'h1E,7'h1E,7'h1E,7'h1E,7'h1E,7'h1E,7'h1E,7'h1E};
                    else
                        encoded_ctrl_words <= 56'd0;
                end
                8'b00011111: begin
                    if (encoder_data_in[39:0] == 40'hFB07070707)
                        encoded_ctrl_words <= {encoder_data_in[63:40], 4'h0, 7'h00, 7'h00, 7'h00, 7'h00};
                    else if (encoder_data_in[39:0] == 40'h9C07070707)
                        encoded_ctrl_words <= {encoder_data_in[63:40], 4'hF, 7'h00, 7'h00, 7'h00, 7'h00};
                    else
                        encoded_ctrl_words <= 56'd0;
                end
                8'b00000001: begin
                    encoded_ctrl_words <= (encoder_data_in[7:0] == 8'hFB) ? {encoder_data_in[63:8]} : 56'd0;
                end
                8'b11111110: begin
                    encoded_ctrl_words <= (encoder_data_in[63:8] == 56'h070707070707FD) ?
                                            {7'h00,7'h00,7'h00,7'h00,7'h00,7'h00,6'b000000,encoder_data_in[7:0]} : 56'd0;
                end
                8'b11111100: begin
                    encoded_ctrl_words <= (encoder_data_in[63:16] == 48'h0707070707FD) ?
                                            {7'h00,7'h00,7'h00,7'h00,7'h00,5'b00000,encoder_data_in[15:0]} : 56'd0;
                end
                8'b11111000: begin
                    encoded_ctrl_words <= (encoder_data_in[63:24] == 40'h07070707FD) ?
                                            {7'h00,7'h00,7'h00,7'h00,4'b0000,encoder_data_in[23:0]} : 56'd0;
                end
                8'b11110000: begin
                    encoded_ctrl_words <= (encoder_data_in[63:32] == 32'h070707FD) ?
                                            {7'h00,7'h00,7'h00,3'b000,encoder_data_in[31:0]} : 56'hFFFFFFF;
                end
                8'b11100000: begin
                    encoded_ctrl_words <= (encoder_data_in[63:40] == 24'h0707FD) ?
                                            {7'h00,7'h00,2'b00,encoder_data_in[39:0]} : 56'd0;
                end
                8'b11000000: begin
                    encoded_ctrl_words <= (encoder_data_in[63:48] == 16'h07FD) ?
                                            {7'h00,1'b0,encoder_data_in[47:0]} : 56'd0;
                end
                8'b10000000: begin
                    encoded_ctrl_words <= (encoder_data_in[63:56] == 8'hFD) ? encoder_data_in[55:0] : 56'd0;
                end
                8'b11110001: begin
                    encoded_ctrl_words <= ({encoder_data_in[63:32], encoder_data_in[7:0]} == 40'h070707079C) ?
                                            {7'h00,7'h00,7'h00,7'h00,encoder_data_in[31:8],4'b1111} : 56'd0;
                end
                8'b00010001: begin
                    if ({encoder_data_in[39:32], encoder_data_in[7:0]} == 16'h9C9C)
                        encoded_ctrl_words <= {encoder_data_in[63:40], 8'hFF, encoder_data_in[31:8]};
                    else if ({encoder_data_in[39:32], encoder_data_in[7:0]} == 16'hFB9C)
                        encoded_ctrl_words <= {encoder_data_in[63:40], 8'h0F, encoder_data_in[31:8]};
                    else
                        encoded_ctrl_words <= 56'd0;
                end
                default: encoded_ctrl_words <= 56'd0;
            endcase
    end

    //----------------------------------------------------------------------------
    // Optimized sequential logic for sync_ctrl_word and type_field using conditional operators
    //----------------------------------------------------------------------------
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_ctrl_word <= 2'b00;
            type_field     <= 8'b0;
        end else begin
            sync_ctrl_word <= (encoder_control_in != 8'b00000000) ? 2'b10 : 2'b00;
            type_field     <= get_output(encoder_data_in, encoder_control_in);
        end
    end

    //----------------------------------------------------------------------------
    // Combinational output logic
    //----------------------------------------------------------------------------
    always_comb begin
        if (|encoder_control_in)
            encoder_data_out = {sync_ctrl_word, type_field, encoded_ctrl_words};
        else
            encoder_data_out = {sync_word, encoded_data};
    end

endmodule