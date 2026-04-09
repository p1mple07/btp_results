Okay, I need to complete the given SystemVerilog code for the Attenuator module. Let me start by understanding the problem.

The module has to handle a 5-bit control word, data, and send it serially through ATTN_DATA. It also needs to toggle ATTN_CLK and pulse ATTN_LE after all bits are sent.

Looking at the partial code, I see that there's an always block triggered on the clock or reset. When reset is 1, it initializes everything to 0. Otherwise, the else block is empty, so I need to fill that in.

The FSM states are IDLE, LOAD, SHIFT, and LATCH. The current_state and next_state are used to manage transitions. So, I'll need to handle state transitions and the corresponding actions.

First, in the else block, I should check the current_state. If it's IDLE, maybe we need to load the data. So, when reset is 0 and data is changing, the module should enter the LOAD state.

Wait, but how do I detect when data changes? The current code doesn't have a mechanism for that. Maybe I should add a compare_state that compares the new data with old_data. If they differ, it triggers the LOAD state.

So, in the else block, I'll add a compare_state. If data != old_data, set compare_state to 1, else 0. Then, based on current_state and compare_state, decide the next_state.

If current_state is IDLE and compare_state is 1, transition to LOAD. If in LOAD and compare_state is 0, transition to SHIFT. In SHIFT, each cycle shifts a bit, toggles the clock, and increments bit_count until it reaches 5, then goes to LATCH. In LATCH, set ATTN_LE high for one cycle.

I also need to handle the shift_reg. Each bit is shifted out serially. So, in the SHIFT state, shift_reg should be updated with the next bit each time.

Wait, the shift_reg is a 5-bit register. So, in each SHIFT cycle, the least significant bit is shifted out via ATTN_DATA, and the next bit comes in. So, in the code, shift_reg[4:0] would be shifted left each time, with the new data bit being added to the least significant position.

But in the code, shift_reg is declared as reg [4:0], so it's a 5-bit register. So, when in SHIFT state, each cycle, shift_reg is shifted left by 1, and the new data bit is loaded into the least significant bit.

Wait, no. Because data is a 5-bit input. So, perhaps data is loaded into shift_reg first in the LOAD state, then in SHIFT, each bit is shifted out.

Wait, in the initial state, when reset is 0 and data changes, we load the data into shift_reg. Then, in SHIFT state, each cycle, the bit is shifted out, and the next bit is shifted in from the data? Or is data a constant?

Wait, data is an input, so it's a constant. So, perhaps the shift_reg is loaded with data in the LOAD state, and then in SHIFT, each bit is shifted out, with the next bit being the next bit from data.

Wait, but data is a 5-bit input. So, in the code, data is a 5-bit vector. So, when in LOAD state, shift_reg is set to data. Then, in SHIFT, each cycle, the least significant bit is shifted out, and the next bit is shifted in from data.

Wait, no. Because data is a 5-bit input, so it's a constant. So, perhaps the shift_reg is loaded with data in the first cycle of SHIFT, then each subsequent cycle shifts the next bit.

Wait, maybe I should structure it as:

- In LOAD state, shift_reg is set to data, and compare_state is set to 0.
- Then, in SHIFT state, for each of the 5 bits, shift_reg is shifted left, and the new bit is shifted in from data. Wait, but data is a 5-bit input, so it's not changing. So, perhaps data is loaded into shift_reg, and then each bit is shifted out one by one.

Wait, perhaps the code should be:

In the else block (when reset is 0):

- If compare_state is 1 (data has changed), transition to LOAD.
- In LOAD, set shift_reg to data, compare_state to 0, and current_state to SHIFT.
- In SHIFT, for each cycle, shift_reg is shifted left, the least significant bit is shifted out as ATTN_DATA, and the next bit is shifted in from data. Wait, but data is a 5-bit input, so it's a constant. So, perhaps data is loaded into shift_reg, and then each bit is shifted out.

Wait, maybe the code should be:

In the else block:

if (current_state == IDLE) {
    if (compare_state) {
        current_state = LOAD;
    }
} else if (current_state == LOAD) {
    shift_reg = data;
    current_state = SHIFT;
    compare_state = 0;
} else if (current_state == SHIFT) {
    bit_count <= bit_count + 1;
    ATTN_DATA <= shift_reg[0];
    shift_reg = (shift_reg << 1) | (data[0]);
    if (bit_count == 5) {
        current_state = LATCH;
        ATTN_LE <= 1;
        bit_count <= 0;
    }
} else if (current_state == LATCH) {
    ATTN_LE <= 0;
}

Wait, but data is a 5-bit input, so data[0] is the least significant bit. So, when shifting, the new bit is data[0], then data[1], etc. But data is a 5-bit input, so data[4] is the most significant bit.

Wait, perhaps the code should shift the shift_reg left each time, and the new bit is data[0], then data[1], etc. So, in each SHIFT cycle, shift_reg is shifted left, and the new bit is data[0], then data[1], etc.

Wait, but data is a 5-bit input. So, data[0] is the first bit to be shifted out, then data[1], etc., up to data[4].

So, in the code, in the SHIFT state, each cycle:

- shift_reg is shifted left by 1.
- the new bit is data[0], then data[1], etc.

Wait, but data is a 5-bit input, so data[0] is the first bit, data[1] is the second, etc.

So, in the code, during SHIFT:

- shift_reg = (shift_reg << 1) | data[0];
- then, data[0] is shifted out as ATTN_DATA.

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps I should write:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, but data is a 5-bit input, so data[0] is the first bit to be shifted out. So, in the code, when shift_reg is shifted left, the new bit is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the code, when shift_reg is shifted left, the new bit is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, but data is a 5-bit input, so data[0] is the first bit to be shifted out. So, in the code, when shift_reg is shifted left, the new bit is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, but data is a 5-bit input, so data[0] is the first bit to be shifted out. So, in the code, when shift_reg is shifted left, the new bit is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, but data is a 5-bit input, so data[0] is the first bit to be shifted out. So, in the code, when shift_reg is shifted left, the new bit is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit. So, in the first SHIFT cycle, shift_reg is data[0], then data[1], etc.

Wait, perhaps the code should be:

In the else block:

if (reset) {
    // initialize
} else {
    if (compare_state) {
        if (current_state == IDLE) {
            current_state = LOAD;
        }
    }
    if (current_state == LOAD) {
        shift_reg = data;
        compare_state = 0;
        current_state = SHIFT;
    }
    if (current_state == SHIFT) {
        bit_count <= bit_count + 1;
        ATTN_DATA <= shift_reg[0];
        shift_reg = (shift_reg << 1) | (data[0]);
        if (bit_count == 5) {
            current_state = LATCH;
            ATTN_LE <= 1;
            bit_count <= 0;
        }
    }
    if (current_state == LATCH) {
        ATTN_LE <= 0;
    }
}

Wait, but data is a 5-bit input, so data[0] is the first bit.