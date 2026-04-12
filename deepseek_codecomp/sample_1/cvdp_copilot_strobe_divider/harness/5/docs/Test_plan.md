#### **Objective**
To verify the functionality of the `strobe_divider` module under various conditions, including all valid parameter configurations, edge cases, and backpressure scenarios.

---

#### **Test Cases**
| **Test Case ID** | **Description**                                                  | **Latency_g** | **Expected Result**                              |
|-------------------|------------------------------------------------------------------|---------------|-------------------------------------------------|
| TC_01             | Reset behavior verification                                     | Both          | Outputs reset; counters cleared.               |
| TC_02             | Division ratio = 1 (basic operation)                           | Both          | `Out_Valid` asserted on every second pulse.    |
| TC_03             | Division ratio = 0 (bypass mode)                               | Both          | `Out_Valid` asserted on every `In_Valid`.      |
| TC_04             | `Out_Ready` deassertion (backpressure)                         | Both          | `Out_Valid` held high until `Out_Ready = 1`.   |
| TC_05             | Pulse generation with gaps in `In_Valid`                       | Both          | Correct output pulses generated despite gaps.  |
| TC_06             | Division ratio = MaxRatio_g                                    | Both          | `Out_Valid` asserted after the max ratio.      |
| TC_07             | Verify `Latency_g = 0` timing                                  | 0             | Immediate `Out_Valid` transitions.            |
| TC_08             | Verify `Latency_g = 1` timing                                  | 1             | `Out_Valid` delayed by one clock cycle.        |
| TC_09             | Mixed `In_Ratio` values                                        | Both          | Correct behavior across multiple `In_Ratio`.   |
| TC_10             | Reset assertion during ongoing operation                       | Both          | Outputs reset; counters reinitialize.          |

---