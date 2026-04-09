
valid_next = 1'b0;

if (start) begin
    // Step-1: Initialize
    // A = 0 => upper AW bits all zero
    // Q = dividend => lower WIDTH bits of aq
    // so zero‐extend: { (AW)'b0, dividend }
    aq_next = { {AW{1'b0}}, dividend };
    // zero‐extend divisor into AW bits
    m_next   = {1'b0, divisor};
    n_next   = WIDTH;
    // We do not set the final quotient/remainder yet
    // Move to BUSY
    state_next = BUSY;
end
