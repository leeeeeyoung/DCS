module FSM(
	// Input signals
	clk,
	rst_n,
	in_valid,
	op,
    A,
    B,
	// Output signals
    pred_taken,
    state
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [1:0] op;
input [3:0] A, B;
output logic pred_taken;
output logic [1:0] state;

//---------------------------------------------------------------------
//   REG AND WIRE DECLARATION                         
//---------------------------------------------------------------------

logic [1:0] next_state;
logic branch_taken;

//---------------------------------------------------------------------
//   YOUR DESIGN                        
//---------------------------------------------------------------------

always_comb begin
    case(op)
        2'b00: branch_taken = (A == B);
        2'b01: branch_taken = (A != B);
        2'b10: branch_taken = (A < B);
        2'b11: branch_taken = (A >= B);
        default: branch_taken = 0;
    endcase
end

always_comb begin
    case(state)
        2'b00: next_state = branch_taken ? 2'b01 : 2'b00;
        2'b01: next_state = branch_taken ? 2'b11 : 2'b00;
        2'b10: next_state = branch_taken ? 2'b11 : 2'b00;
        2'b11: next_state = branch_taken ? 2'b11 : 2'b10;
        default: next_state = 2'b00;
    endcase
end

always_ff @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= 0;
        pred_taken <= 0;
    end 
	else if(in_valid) begin
        state <= next_state;
		if(next_state == 2'b10 || next_state == 2'b11) begin
			pred_taken <= 1'b1;
		end
		else begin
			pred_taken <= 0;
		end
    end
end

endmodule
