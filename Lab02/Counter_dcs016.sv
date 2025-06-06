module Counter(
    // Input signals
	clk, 
	rst_n, 
	in_valid,  
	in_num,  
    // Output signals
	out_num
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n;
input in_valid; 
input [4:0] in_num;
output logic [4:0] out_num;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [4:0] counter;
logic [4:0] target_num;
logic counting;
logic [4:0] next_counter;
logic counting_next;

//---------------------------------------------------------------------
//   DESIGN                        
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 5'b0;
        target_num <= 5'b0;
        counting <= 1'b0;
    end
    else begin
        counter <= next_counter;
        counting <= counting_next;
        if (in_valid)
            target_num <= in_num;
    end
end

always_comb begin
    next_counter = counter;
    counting_next = counting;
    if (in_valid) begin
        next_counter = 5'b0;
        counting_next = 1'b1;
    end
    else if (counting) begin
        if (counter < target_num) begin
            next_counter = counter + 1'b1;
        end
        else begin
            counting_next = 1'b0;
        end
    end
end

assign out_num = counter;

endmodule