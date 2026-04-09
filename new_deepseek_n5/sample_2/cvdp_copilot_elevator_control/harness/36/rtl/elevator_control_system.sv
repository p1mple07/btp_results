module Binary2BCD(input [7:0] num, output reg [3:0]thousand, output [3:0] hundred, output [3:0] ten, output [3:0] one);
    reg [19:0] shift;
    integer i;
    
    always @(num)
    begin
        shift[19:0] = 0;
        for(i=0;i<8;i=i+1)
        begin
            if(shift[11:8]>=5)
                shift[11:8]=shift[11:8] +3;
            if(shift[15:12]>=5)
                    shift[15:12]=shift[15:12] +3; 
            if(shift[19:16]>=5)
                shift[19:16]=shift[19:16] +3;
        end
        hundred=shift[19:16];
        ten=shift[15:12];
        one=shift[11:8];
        thousand=4'b0000;
        
    end
    
endmodule

module floor_to_seven_segment (
    input wire [7:0] floor_display,
    output reg [6:0] seven_seg_out,
    output [3:0] seven_seg_out_anode,
    output [3:0] thousand,
    output [3:0] hundred,
    output [3:0] ten,
    output [3:0] one
)
    //Internal signals
     reg [6:0]sseg_temp=7'b1111111;
     reg [3:0]an_temp = 4'b1110 ;
     reg [17:0] count=0; //the 18 bit counter which allows us to multiplex at 1000Hz

     always @ (posedge clk)
      begin
        count <= count + 1;
      end

    //code for display multiple digits
always @(*) begin
    case (count[17:16]) // Using only the 2 MSBs of the counter
        2'b00: // When the 2 MSBs are 00, enable the fourth display
        begin
            case (one)
                4'd0: sseg_temp = 7'b1111110; // Display 0
                4'd1: sseg_temp = 7'b0110000; // Display 1
                4'd2: sseg_temp = 7'b1101101; // Display 2
                4'd3: sseg_temp = 7'b1111001; // Display 3
                4'd4: sseg_temp = 7'b0110011; // Display 4
                4'd5: sseg_temp = 7'b1011011; // Display 5
                4'd6: sseg_temp = 7'b1011111; // Display 6
                4'd7: sseg_temp = 7'b1110000; // Display 7
                4'd8: sseg_temp = 7'b1111111; // Display 8
                4'd9: sseg_temp = 7'b1111011; // Display 9
                default: sseg_temp = 7'b0000000; // Blank display
            endcase
            an_temp = 4'b1110; // Enable the fourth display
        end
        
        2'b01: // When the 2 MSBs are 01, enable the third display
        begin
            case (ten)
                4'd0: sseg_temp = 7'b1111110; // Display 0
                4'd1: sseg_temp = 7'b0110000; // Display 1
                4'd2: sseg_temp = 7'b1101101; // Display 2
                4'd3: sseg_temp = 7'b1111001; // Display 3
                4'd4: sseg_temp = 7'b0110011; // Display 4
                4'd5: sseg_temp = 7'b1011011; // Display 5
                4'd6: sseg_temp = 7'b1011111; // Display 6
                4'd7: sseg_temp = 7'b1110000; // Display 7
                4'd8: sseg_temp = 7'b1111111; // Display 8
                4'd9: sseg_temp = 7'b1111011; // Display 9
                default: sseg_temp = 7'b0000000; // Blank display
            endcase
            an_temp = 4'b1101; // Enable the third display
        end

        2'b10: // When the 2 MSBs are 10, enable the second display
        begin
            case (hundred)
                4'd0: sseg_temp = 7'b1111110; // Display 0
                4'd1: sseg_temp = 7'b0110000; // Display 1
                4'd2: sseg_temp = 7'b1101101; // Display 2
                4'd3: sseg_temp = 7'b1111001; // Display 3
                4'd4: sseg_temp = 7'b0110011; // Display 4
                4'd5: sseg_temp = 7'b1011011; // Display 5
                4'd6: sseg_temp = 7'b1011111; // Display 6
                4'd7: sseg_temp = 7'b1110000; // Display 7
                4'd8: sseg_temp = 7'b1111111; // Display 8
                4'd9: sseg_temp = 7'b1111011; // Display 9
                default: sseg_temp = 7'b0000000; // Blank display
            endcase
            an_temp = 4'b1011; // Enable the second display
        end

        2'b11: // When the 2 MSBs are 11, enable the first display
        begin
            case (thousand)
                4'd0: sseg_temp = 7'b1111110; // Display 0
                4'd1: sseg_temp = 7'b0110000; // Display 1
                4'd2: sseg_temp = 7'b1101101; // Display 2
                4'd3: sseg_temp = 7'b1111001; // Display 3
                4'd4: sseg_temp = 7'b0110011; // Display 4
                4'd5: sseg_temp = 7'b1011011; // Display 5
                4'd6: sseg_temp = 7'b1011111; // Display 6
                4'd7: sseg_temp = 7'b1110000; // Display 7
                4'd8: sseg_temp = 7'b1111111; // Display 8
                4'd9: sseg_temp = 7'b1111011; // Display 9
                default: sseg_temp = 7'b0000000; // Blank display
            endcase
            an_temp = 4'b0111; // Enable the first display
        end
    endcase
end

    //Binary to BCD covertor to receive seprate bits for ones, tens, hundred, thousand places
    Binary2BCD B1(.num(floor_display), .thousand(thousand), .hundred(hundred),.ten(ten),.one(one) );

endmodule