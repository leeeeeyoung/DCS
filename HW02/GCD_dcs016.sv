module GCD(
    // Input signals
	clk,
	rst_n,
	in_valid,
    in_data,
    // Output signals
    out_valid,
    out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [3:0] in_data;

output logic out_valid;
output logic [4:0] out_data;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

parameter GET_DATA = 1'd0, OUT_DATA = 1'd1;

logic state, next_state;
logic [3:0] counter, next_counter;

logic [4:0] pair_sum [2:0];
logic [4:0] next_pair_sum [2:0];
logic [1:0] pair_counter, next_pair_counter;

logic [3:0] even_temp, next_even_temp;
logic [3:0] odd_temp, next_odd_temp;
logic even_counter, next_even_counter;
logic odd_counter, next_odd_counter;

logic [4:0] a, b, temp_a, temp_b, next_temp_a, next_temp_b;
logic get_new_pair;
logic [4:0] gcd, next_gcd;

logic [2:0] out_counter, next_out_counter;
logic next_out_valid;
logic [4:0] next_out_data;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

always_ff @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= 0;
        counter <= 0;
        pair_sum[0] <= 0;
        pair_sum[1] <= 0;
        pair_sum[2] <= 0;
        pair_counter <= 0;
        even_temp <= 0;
        odd_temp <= 0;
        even_counter <= 0;
        odd_counter <= 0;
        gcd <= 0;
        out_counter <= 0;
        out_valid <= 0;
        out_data <= 0;
        temp_a <= 0;
        temp_b <= 0;
    end
    else begin
        state <= next_state;
        counter <= next_counter;
        pair_sum[0] <= next_pair_sum[0];
        pair_sum[1] <= next_pair_sum[1];
        pair_sum[2] <= next_pair_sum[2];
        pair_counter <= next_pair_counter;
        even_temp <= next_even_temp;
        odd_temp <= next_odd_temp;
        even_counter <= next_even_counter;
        odd_counter <= next_odd_counter;
        gcd <= next_gcd;
        out_counter <= next_out_counter;
        out_valid <= next_out_valid;
        out_data <= next_out_data;
        temp_a <= next_temp_a;
        temp_b <= next_temp_b;
    end
end

always_comb begin
    next_state = state;
    next_counter = counter;
    next_pair_sum[0] = pair_sum[0];
    next_pair_sum[1] = pair_sum[1];
    next_pair_sum[2] = pair_sum[2];
    next_pair_counter = pair_counter;
    next_even_temp = even_temp;
    next_odd_temp = odd_temp;
    next_even_counter = even_counter;
    next_odd_counter = odd_counter;
    next_gcd = gcd;
    next_out_counter = out_counter;
    next_out_valid = out_valid;
    next_out_data = out_data;
    next_temp_a = temp_a;
    next_temp_b = temp_b;

    a = 0;
    b = 0;
    get_new_pair = 0;

    case(state)

        GET_DATA: begin
            next_out_valid = 0;
            next_out_data = 0;
            next_out_counter = 0;
            if(in_valid) begin
                next_counter = counter + 4'd1;
                if(in_data[0]) begin
                    if(!odd_counter) begin
                        next_odd_temp = in_data;
                        next_odd_counter = 1'b1;
                    end
                    else begin
                        next_pair_sum[pair_counter] = odd_temp + in_data;
                        next_pair_counter = pair_counter + 2'd1;
                        next_odd_counter = 0;
                        get_new_pair = 1'b1;
                    end
                end
                else begin
                    if(!even_counter) begin
                        next_even_temp = in_data;
                        next_even_counter = 1'b1;
                    end
                    else begin
                        next_pair_sum[pair_counter] = even_temp + in_data;
                        next_pair_counter = pair_counter + 2'd1;
                        next_even_counter = 0;
                        get_new_pair = 1'b1;
                    end
                end
            end
            if(counter == 4'd5) begin
                a = pair_sum[0];
                b = pair_sum[1];
                if(get_new_pair) begin
                    b = next_pair_sum[1];
                end
                a = a % b; a = a ^ b; b = a ^ b; a = a ^ b;
                next_temp_a = a;
                next_temp_b = b;
            end
            else if(counter == 4'd6 ||counter == 4'd7) begin
                a = temp_a;
                b = temp_b;
                if(b != 0) begin
                    a = a % b; a = a ^ b; b = a ^ b; a = a ^ b;
                end
                next_temp_a = a;
                next_temp_b = b;
            end
            if(counter == 4'd7) begin
                next_counter = 0;
                next_even_counter = 0;
                next_odd_counter = 0;
                next_pair_counter = 0;
                next_out_counter = 3'd1;
                next_out_valid = 1'b1;
                next_out_data = pair_sum[0];
                next_state = OUT_DATA;
            end
        end

        OUT_DATA: begin
            case(out_counter)
                3'd1: begin
                    a = temp_a;
                    b = temp_b;
                    if(b != 0) begin
                        a = a % b; a = a ^ b; b = a ^ b; a = a ^ b;
                    end
                    if(b != 0) begin
                        a = a % b; a = a ^ b; b = a ^ b; a = a ^ b;
                    end
                    if(b != 0) begin
                        a = a % b; a = a ^ b; b = a ^ b; a = a ^ b;
                    end
                    next_gcd = a;
                    next_out_data = pair_sum[1];
                end
                3'd2: begin
                    a = gcd;
                    b = pair_sum[2];
                    a = a % b; a = a ^ b; b = a ^ b; a = a ^ b;
                    if(b != 0) begin
                        a = a % b; a = a ^ b; b = a ^ b; a = a ^ b;
                    end
                    if(b != 0) begin
                        a = a % b; a = a ^ b; b = a ^ b; a = a ^ b;
                    end
                    next_temp_a = a;
                    next_temp_b = b;
                    next_out_data = pair_sum[2];
                end
                3'd3: begin
                    a = temp_a;
                    b = temp_b;
                    if(b != 0) begin
                        a = a % b; a = a ^ b; b = a ^ b; a = a ^ b;
                    end
                    if(b != 0) begin
                        a = a % b; a = a ^ b; b = a ^ b; a = a ^ b;
                    end
                    if(b != 0) begin
                        a = a % b; a = a ^ b; b = a ^ b; a = a ^ b;
                    end
                    next_out_data = a;
                    next_state = GET_DATA;
                end
            endcase
            next_out_counter = out_counter + 3'd1;
        end
    endcase
end
endmodule

