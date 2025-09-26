module fsm (
    input reset,
    input clk, 
    input data_in,
    output reg seq_detected
);

parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;

reg [1:0] current_state, next_state;

// 1. Sequential Logic: The State Register
always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= S0;
    end else begin
        current_state <= next_state;
    end
end

// 2. Combinational Logic: The Next-State Logic
always @(*) begin
    // Default to staying in the current state unless a transition is defined
    next_state = current_state; 
    
    case (current_state)
        S0: begin
            if (data_in == 1'b1) begin
                next_state = S1;
            end else begin
                next_state = S0;
            end
        end
        S1: begin
            if (data_in == 1'b0) begin
                next_state = S2;
            end else begin
                next_state = S1;
            end
        end
        S2: begin
            if (data_in == 1'b1) begin
                next_state = S3;
            end else begin
                next_state = S0;
            end
        end
        S3: begin // Added the logic for S3
            if (data_in == 1'b1) begin
                next_state = S1; // Overlapping sequence (the last '1' is the start of the next '101')
            end else begin
                next_state = S0; // No overlap, reset to initial state
            end
        end
        default: begin 
            next_state = S0;
        end
    endcase
end

// 3. Combinational Logic: The Output
always @(*) begin
    if (current_state == S3) begin
        seq_detected = 1'b1;
    end else begin
        seq_detected = 1'b0;
    end
end
endmodule