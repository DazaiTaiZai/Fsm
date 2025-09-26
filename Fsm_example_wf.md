FSMs are a cornerstone of digital design and a natural fit for implementation in **Verilog** and other **Hardware Description Languages (HDLs)**. In this context, an FSM provides a structured and synthesizable way to control the behavior of a digital circuit.

### FSM Design in HDLs

Implementing an FSM in Verilog involves three key components that are typically represented as separate `always` blocks for clarity and good design practice. This is known as the **three-process FSM design method**.

#### 1\. The State Register

This `always @(posedge clk or posedge reset)` block is responsible for updating the current state of the machine. It's a **sequential** process because it's triggered by a clock edge. On each positive clock edge, the current state is updated to the value of the next state. A reset signal is usually included to initialize the FSM to its starting state.

#### 2\. The Next-State Logic

This `always @(*)` block is a **combinational** process. It determines the **next state** based on the **current state** and the FSM's inputs. This is where you define all your state transitions. You typically use a `case` statement to handle each possible current state and the corresponding inputs to determine where to transition next.

#### 3\. The Output Logic

This `always @(*)` block is also a **combinational** process. It generates the FSM's outputs.

  * For a **Moore** machine, the output depends **only on the current state**. The logic here is simple: based on the current state, a specific output is assigned.
  * For a **Mealy** machine, the output depends on both the **current state and the inputs**. The logic is similar to the next-state logic, often using a `case` statement on the current state and nested logic for the inputs.

-----

### Example: A Simple 2-Bit Sequence Detector

Let's illustrate with a simple FSM that detects the sequence "11". The FSM has three states:

  * **S0 (Initial State):** No bits of the sequence have been seen.
  * **S1:** The first '1' has been seen.
  * **S2:** The second '1' has been seen.

We'll use a simple **binary encoding** to represent the states: `S0 = 2'b00`, `S1 = 2'b01`, and `S2 = 2'b10`.

```verilog
module sequence_detector (
  input clk,
  input reset,
  input data_in,
  output reg seq_detected
);

// State encoding
parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10;

// Internal registers for states
reg [1:0] current_state, next_state;

// Process 1: State Register
always @(posedge clk or posedge reset) begin
  if (reset) begin
    current_state <= S0;
  end else begin
    current_state <= next_state;
  end
end

// Process 2: Next-State Logic
always @(*) begin
  next_state = current_state; // Default transition is to stay in the same state
  case (current_state)
    S0: begin
      if (data_in == 1'b1)
        next_state = S1;
      else
        next_state = S0;
    end
    S1: begin
      if (data_in == 1'b1)
        next_state = S2;
      else
        next_state = S0; // If '0' is received, go back to the start
    end
    S2: begin
      next_state = S0; // The sequence is detected, so reset for the next sequence
    end
    default: next_state = S0;
  endcase
end

// Process 3: Output Logic (Moore-style)
always @(*) begin
  if (current_state == S2)
    seq_detected = 1'b1;
  else
    seq_detected = 1'b0;
end

endmodule
```

In this example, the FSM is a **Moore machine** because the output `seq_detected` is determined solely by being in state `S2`, not by a specific input. The three separate `always` blocks provide a clear and organized design that is easy to read, debug, and synthesize into a functional digital circuit.