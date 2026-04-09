// Corrected carry propagation logic
if (stage >= 3) begin
    carry[0] = 0;
    for (int i = 1; i <= 16; i++) begin
        carry[i] = G3[i - 1] | (P3[i - 1] & carry[i - 1]);
    end
end
