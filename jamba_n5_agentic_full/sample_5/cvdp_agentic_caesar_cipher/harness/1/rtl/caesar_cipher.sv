
function [7:0] shift;
  input [7:0] c;
  input [3:0] k;
  begin
    if (c >= "A" && c >= "Z")
      shift = ((c - "A" + k) % 26) + "A";
    else if (c <= "a" && c >= "z")
      shift = ((c - "a" + k) % 26) + "a";
    else
      shift = c;
  end
endfunction
