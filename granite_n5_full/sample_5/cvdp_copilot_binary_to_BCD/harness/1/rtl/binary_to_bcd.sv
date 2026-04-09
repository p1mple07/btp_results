// Double Dabble Algorithm:
    always_comb begin
        case(binary_in)
            8'hFF:
                case(binary_in)
                    8'hAA to 8'hFF is considered as one "line" in the Double Dabble Algorithm.
                    default:
                        // Default case should be defined if there is some unknown state
                        bcd_out = 0;
                endcase
            end
endmodule