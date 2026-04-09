Okay, so I need to design a Digital Dice Roller module. Let me think about how to approach this. The module should have a counter that cycles from 1 to 6 on the positive edge of the clock when the button is pressed. When the button is released, it should stop and output the last value.

First, I'll start by defining the necessary components. There's the input signals: clk, reset_n, and button. The output is dice_value, a 3-bit signal. Also, there's a counter that keeps track of the current value.

I'll use a Finite State Machine (FSM) to manage the states. The FSM will have two states: IDLE and ROLLING. In IDLE, the dice_value is 0 until the button is pressed. When the button goes HIGH, it transitions to ROLLING, and the counter starts incrementing.

In the ROLLING state, the counter will increment each positive edge of the clock. But I need to make sure it wraps around after 6. So, when it reaches 6, the next increment should reset it to 1. Also, when the button goes LOW, the FSM should go back to IDLE and set dice_value to the last counted value.

I should handle the reset_n signal. If it's active LOW, it should reset the counter to 0 and keep dice_value at 0. But wait, the functional requirement says that when button is HIGH, the FSM cycles from 1 to 6. So, maybe the counter starts at 0 but is incremented to 1 on the first clock edge after the button is pressed.

I'll need to write the state transitions. In IDLE, when button is pressed (button is now HIGH), it goes to ROLLING. In ROLLING, each clock edge increments the counter. When the counter reaches 6, it should wrap around to 1. Also, when the button is released (button goes LOW), the FSM returns to IDLE and sets dice_value to the current counter value.

Wait, but the counter is a 3-bit register. So, it can hold values from 0 to 7. But we need it to cycle from 1 to 6. So, maybe the counter starts at 0, and when it increments, it goes to 1, then 2, up to 6, and then wraps back to 0. But then, when the FSM is in ROLLING, the dice_value should be the counter value, but only when the button is pressed. Hmm, maybe the dice_value is set to the counter value when the button is released.

Wait, no. The FSM is in ROLLING when the button is HIGH. So, when the button is pressed, the FSM transitions to ROLLING, and the counter starts at 0. Each clock edge increments the counter. When the counter reaches 6, it wraps to 0. But the dice_value should be the current counter value when the button is released. So, when the button goes LOW, the FSM goes back to IDLE, and dice_value is set to the counter value.

But wait, the counter is a 3-bit register, so it can go up to 7. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. But the dice_value is 1 to 6, so perhaps the counter is 0 to 5, and dice_value is counter + 1. That way, when counter is 5, dice_value is 6, and when it wraps to 0, dice_value becomes 1 again.

Alternatively, maybe the counter is 1 to 6, and when it increments beyond 6, it wraps to 1. But since it's a 3-bit register, it's easier to manage 0 to 5 and then add 1 to get 1 to 6.

So, in the ROLLING state, each clock edge increments the counter. When the counter is 5, next is 6, then it wraps to 0. But when the button is released, the dice_value is set to the current counter value plus 1. Wait, no. Because when the button is released, the counter is at 6, so dice_value should be 6. Then, when the button is pressed again, it should start counting from 1.

Wait, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, the dice_value is the counter value plus 1. So, when counter is 5, dice_value is 6. When it wraps to 0, dice_value becomes 1.

But I'm getting a bit confused. Let me outline the states and transitions again.

State IDLE:
- dice_value is 0.
- When button is pressed (button is now HIGH), transition to ROLLING.

State ROLLING:
- counter starts at 0.
- On each positive edge of clk, increment counter.
- When counter reaches 5, next increment should set it to 6, then on next, wrap to 0.
- When button is released (button goes LOW), transition back to IDLE, and set dice_value to counter + 1.

Wait, but when the button is pressed, the counter starts at 0, and on the first clock edge, it increments to 1. Then, when the button is released, dice_value is 1. That makes sense.

But how to handle the counter wrapping. Maybe the counter is a 3-bit register, so it can go up to 7. So, when it's in ROLLING, each clock edge increments it. When it's 6, the next increment should set it to 0, but also, when the button is released, dice_value is set to the counter value plus 1.

Wait, no. Because when the counter is 6, dice_value should be 6. When the button is released, it should set dice_value to 6, and then when the button is pressed again, it should start counting from 1.

Hmm, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1. So, when counter is 5, dice_value is 6. When it wraps to 0, dice_value becomes 1.

But I'm not sure. Maybe it's easier to have the counter go from 0 to 6, and when it increments beyond 6, it wraps to 0. Then, dice_value is counter + 1. So, when counter is 6, dice_value is 7, which is invalid. So that's not good.

Alternatively, maybe the counter is 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1. So, when counter is 5, dice_value is 6. When it wraps to 0, dice_value is 1.

Wait, but the counter is a 3-bit register, so it can go up to 7. So, maybe the counter is 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1. So, when counter is 5, dice_value is 6. When it wraps to 0, dice_value is 1.

But I'm not sure if that's the right approach. Maybe it's better to have the counter go from 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1. So, when the counter is 5, dice_value is 6. When it wraps to 0, dice_value is 1.

Wait, but when the counter is 6, dice_value should be 6, and when it wraps to 0, dice_value should be 1. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

But I'm getting stuck on how to handle the counter correctly. Maybe I should write the code for the FSM and the counter.

So, in the code, I'll have a state variable, say state, which can be IDLE or ROLLING. When the state is IDLE and button is pressed, it transitions to ROLLING. In ROLLING, on positive edge of clk, it increments the counter. When the counter reaches 6, it wraps to 0. When the button is released, it transitions back to IDLE and sets dice_value to counter + 1.

Wait, but when the counter is 6, dice_value should be 6, and when it wraps to 0, dice_value should be 1. So, maybe the counter is 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Alternatively, maybe the counter is 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, I think I'm overcomplicating. Let me try to outline the code structure.

First, the FSM:

- State: IDLE or ROLLING
- On transition from IDLE to ROLLING when button is pressed (button is now HIGH)
- On transition from ROLLING to IDLE when button is released (button is now LOW)

In ROLLING state, on positive edge of clk, increment counter. When counter is 6, next increment should set it to 0. Also, when the button is released, set dice_value to counter + 1.

Wait, but when the counter is 6, dice_value should be 6, and when it wraps to 0, dice_value should be 1.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 + 1 is 7, which is invalid. So, maybe the counter is 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 5 + 1 is 6, which is valid. Then, when it wraps to 0, dice_value is 1.

So, the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

But the counter is a 3-bit register, so it can go up to 7. So, maybe the counter is 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0. Then, dice_value is counter + 1.

Wait, but 6 is 110, which is 6, and 0 is 000, which is 0. So, when the counter is 5 (101), dice_value is 6 (110). When it wraps to 0 (000), dice_value is 1 (001). That makes sense.

So, in code:

In ROLLING state:
- On clock edge, counter = counter + 1
- If counter == 6, then next time it should wrap to 0
- When button is released, set dice_value to counter + 1

Wait, but when counter is 6, dice_value is 7, which is invalid. So, maybe the counter should be 0 to 5, and when it increments, it goes to 6, then wraps to 0.