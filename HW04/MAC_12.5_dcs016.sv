module MAC (
    // Input signals
    input clk,
    input rst_n,
    input in_valid,
    input in_mode,
    input [0:7][3:0] in_act,
    input [0:8][3:0] in_wgt,
    // Output signals
    output logic [3:0] out_act_idx,
    output logic [3:0] out_wgt_idx,
    output logic [3:0] out_idx,
    output logic out_valid,
    output logic [0:7][11:0] out_data,
    output logic out_finish
);

parameter IDLE = 1'd0, LOAD = 1'd1;

logic state, next_state;

logic [3:0] next_out_act_idx;
logic [3:0] next_out_wgt_idx;
logic [3:0] next_out_idx;
logic next_out_valid;
logic [0:7][11:0] next_out_data;
logic next_out_finish;

logic flag, next_flag;

logic [0:7][0:7][3:0] Act_Matrix, next_Act_Matrix;

logic [11:0] sum;
logic [0:8][3:0] mul_temp;

always_ff @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
        out_act_idx <= 0;
        out_wgt_idx <= 0;
        out_idx <= 0;
        out_valid <= 0;
        out_data <= 0;
        out_finish <= 0;
        flag <= 0;
        Act_Matrix <= 0;
    end
    else begin
        state <= next_state;
        out_act_idx <= next_out_act_idx;
        out_wgt_idx <= next_out_wgt_idx;
        out_idx <= next_out_idx;
        out_valid <= next_out_valid;
        out_data <= next_out_data;
        out_finish <= next_out_finish;
        flag <= next_flag;
        Act_Matrix <= next_Act_Matrix;
    end
end

always_comb begin
    next_state = state;
    next_out_act_idx = out_act_idx;
    next_out_wgt_idx = out_wgt_idx;
    next_out_idx = out_idx;
    next_out_valid = out_valid;
    next_out_data = out_data;
    next_out_finish = out_finish;
    next_flag = flag;
    next_Act_Matrix = Act_Matrix;
    sum = 0;
    mul_temp = 0;
    case(state)
        IDLE: begin
            next_out_act_idx = 4'b0000;
            next_out_wgt_idx = 4'b1000;
            next_out_idx = 4'b0111;
            next_out_valid = 0;
            next_out_data = 0;
            next_out_finish = 0;
            next_Act_Matrix = 0;
            if(in_valid) begin
                next_flag = in_mode;
                next_state = LOAD;
            end
        end
        LOAD: begin
            next_Act_Matrix[out_act_idx] = in_act;
            if((!flag && out_act_idx > 6) || flag) begin
                next_out_valid = 1'b1;
                if(out_act_idx == 1) begin
                    next_out_idx = 0;
                end
                else begin
                    next_out_idx = out_idx + 1;
                end
                for(int i = 0; i < 8; i++) begin
                    sum = 0;
                    if(flag) begin
                        for(int j = 0; j < 3; j++) begin
                            for(int k = 0; k < 3; k++) begin
                                if((next_out_idx + j - 1) >= 0 && (next_out_idx + j - 1) < 8 && (i + k - 1) >= 0 && (i + k - 1) < 8) begin
                                    mul_temp[j * 3 + k] = next_Act_Matrix[next_out_idx + j - 1][i + k - 1];
                                end
                                else begin
                                    mul_temp[j * 3 + k] = 0;
                                end
                            end
                        end
                    end
                    else begin
                        for(int j = 0; j < 8; j++) begin
                            mul_temp[j] = next_Act_Matrix[i][j];
                        end
                    end
                    for(int l = 0; l < 8; l++) begin
                        sum += mul_temp[l] * in_wgt[l];
                    end
                    if(flag) begin
                        sum += mul_temp[8] * in_wgt[8];
                    end
                    next_out_data[i] = sum;
                end
                next_out_wgt_idx = out_wgt_idx + 1;
                if(next_out_idx == 7 || next_out_idx == 15) begin
                    next_out_finish = 1'b1;
                    next_state = IDLE;
                end
            end
            if(out_act_idx < 7) begin
                next_out_act_idx = out_act_idx + 1;
            end
        end
    endcase
end
endmodule