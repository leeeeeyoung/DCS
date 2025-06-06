module CPU(
    //INPUT
    clk,
    rst_n,
    in_valid,
    instruction,

    //OUTPUT
    out_valid,
    instruction_fail,
    out_0,
    out_1,
    out_2,
    out_3,
    out_4,
    out_5
);
// INPUT
input clk;
input rst_n;
input in_valid;
input [31:0] instruction;

// OUTPUT
output logic out_valid, instruction_fail;
output logic [15:0] out_0, out_1, out_2, out_3, out_4, out_5;

//================================================================
// DESIGN
//================================================================

logic signed [0:5][15:0] reg_file;

logic stage1_valid;
logic [31:0] stage1_instr;

logic stage2_valid;
logic stage2_is_R_type;
logic stage2_instruction_X;
logic [2:0] stage2_rs, stage2_rt, stage2_rd;
logic [4:0] stage2_shamt;
logic [2:0] stage2_funct;
logic signed [15:0] stage2_immediate;

logic stage3_valid;
logic stage3_instruction_X;
logic signed [15:0] stage3_rs_value;
logic signed [15:0] stage3_rt_value;
logic signed [15:0] stage3_res;
logic [2:0] stage3_dest;
logic stage3_do_write;
logic stage3_is_mul;

logic stage4_valid;
logic stage4_instruction_X;
logic signed [15:0] stage4_res;
logic [2:0] stage4_dest;
logic stage4_do_write;
logic stage4_is_mul;
logic [15:0] stage4_mul_1;
logic signed [15:0] stage4_mul_2;
logic signed [15:0] stage4_mul_3;
logic signed [14:0] stage4_mul_4;

logic stage5_valid;
logic stage5_instruction_X;

logic [5:0] opcode;
logic [2:0] rs, rt, rd;
logic [4:0] shamt;
logic [2:0] funct;
logic signed [15:0] imm;
logic is_R, is_I, valid_funct, X_loc;
logic signed [15:0] op1, op2, res;
logic [2:0] dest;
logic do_write;
logic is_mul;

logic signed [30:0] sum;
logic signed [15:0] ans;

logic [15:0] mul_1;
logic signed [15:0] mul_2;
logic signed [15:0] mul_3;
logic signed [14:0] mul_4;

logic [15:0] shift_1;
logic signed [22:0] shift_2;
logic signed [22:0] shift_3;
logic signed [14:0] shift_4;


function automatic logic [2:0] map_to_index(input [4:0] field);
    case (field)
        5'd17: return 3'd0;
        5'd18: return 3'd1;
        5'd8:  return 3'd2;
        5'd23: return 3'd3;
        5'd31: return 3'd4;
        5'd16: return 3'd5;
        default: return 3'd0;
    endcase
endfunction

always_comb begin
    opcode = stage1_instr[31:26];
    rs = map_to_index(stage1_instr[25:21]);
    rt = map_to_index(stage1_instr[20:16]);
    rd = map_to_index(stage1_instr[15:11]);
    shamt = stage1_instr[10:6];
    funct = {stage1_instr[5], stage1_instr[4], stage1_instr[1]};
    imm = stage1_instr[15:0];

    is_R = (opcode == 6'b000000);
    is_I = (opcode == 6'b001000);
    valid_funct = (stage1_instr[5:0] == 6'b100000) || (stage1_instr[5:0] == 6'b011000) || (stage1_instr[5:0] == 6'b000000) || (stage1_instr[5:0] == 6'b000010) || (stage1_instr[5:0] == 6'b110001) || (stage1_instr[5:0] == 6'b110010);
    X_loc = !((is_R && valid_funct) || is_I);
end

always_comb begin
    op1 = reg_file[stage2_rs];
    op2 = reg_file[stage2_rt];
    
    res  = 0;
    is_mul = 0;

    if (stage2_is_R_type) begin
        case (stage2_funct)
            3'b100: res = op1 + op2;
            3'b010: begin
                is_mul = 1;
            end
            3'b000: res = op2 << stage2_shamt;
            3'b001: res = op2 >>> stage2_shamt;
            3'b110: res = (op2 < 0) ? 0 : op2;
            3'b111: begin
                res = op2;
                is_mul = (op2 < 0) ? 1 : 0;
            end
            default: res = 0;
        endcase
    end 
    else begin
        res = op1 + stage2_immediate;
    end
    do_write = !stage2_instruction_X;
    dest = stage2_is_R_type ? stage2_rd : stage2_rt;
end

always_comb begin
    mul_1 = $unsigned(stage3_rs_value[7:0]) * $unsigned(stage3_rt_value[7:0]);
    mul_2 = $signed(stage3_rs_value[15:8]) * $signed({1'b0, stage3_rt_value[7:0]});
    mul_3 = $signed({1'b0, stage3_rs_value[7:0]}) * $signed(stage3_rt_value[15:8]);
    mul_4 = $signed(stage3_rs_value[15:8]) * $signed(stage3_rt_value[15:8]);
end

always_comb begin
    shift_1 = stage4_mul_1;
    shift_2 = stage4_mul_2;
    shift_3 = stage4_mul_3;
    shift_4 = stage4_mul_4;
    sum = shift_1 + (shift_2 << 8) + (shift_3 << 8) + (shift_4 << 16);
    ans = (stage4_is_mul == 0) ? stage4_res : (sum >>> 15);
end

always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_file <= 0;
        stage1_valid <= 0;
        stage2_valid <= 0;
        stage3_valid <= 0;
        stage4_valid <= 0;
        stage5_valid <= 0;
        out_valid <= 0;
        instruction_fail <= 0;
        out_0 <= 0;
        out_1 <= 0;
        out_2 <= 0;
        out_3 <= 0;
        out_4 <= 0;
        out_5 <= 0;
        stage1_instr <= 0;
    end 
    else begin
        stage1_valid <= in_valid;
        if (in_valid) stage1_instr <= instruction;

        stage2_valid <= stage1_valid;
        if (stage1_valid) begin
            stage2_is_R_type <= is_R;
            stage2_instruction_X <= X_loc;
            stage2_rs <= rs;
            stage2_rt <= rt;
            stage2_rd <= rd;
            stage2_shamt <= shamt;
            stage2_funct <= funct;
            stage2_immediate <= imm;
        end

        stage3_valid <= stage2_valid;
        if (stage2_valid) begin
            stage3_instruction_X <= stage2_instruction_X;
            stage3_rs_value <= op1;
            stage3_rt_value <= op2;
            stage3_res <= res;
            stage3_dest <= dest;
            stage3_do_write <= do_write;
            stage3_is_mul <= is_mul;
        end

        stage4_valid <= stage3_valid;
        if (stage3_valid) begin
            stage4_instruction_X <= stage3_instruction_X;
            stage4_res <= stage3_res;
            stage4_dest <= stage3_dest;
            stage4_do_write <= stage3_do_write;
            stage4_is_mul <= stage3_is_mul;
            stage4_mul_1 <= mul_1;
            stage4_mul_2 <= mul_2;
            stage4_mul_3 <= mul_3;
            stage4_mul_4 <= mul_4;
        end

        stage5_valid <= stage4_valid;
        stage5_instruction_X <= stage4_instruction_X;
        if (stage4_valid && stage4_do_write) reg_file[stage4_dest] <= ans;

        out_valid <= stage5_valid;
        instruction_fail <= stage5_valid ? stage5_instruction_X : 0;
        out_0 <= stage5_valid ? reg_file[0] : 0;
        out_1 <= stage5_valid ? reg_file[1] : 0;
        out_2 <= stage5_valid ? reg_file[2] : 0;
        out_3 <= stage5_valid ? reg_file[3] : 0;
        out_4 <= stage5_valid ? reg_file[4] : 0;
        out_5 <= stage5_valid ? reg_file[5] : 0;
    end
end
endmodule