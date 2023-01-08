`timescale 1ps/1ps

`include "../rv_defines.vh"
`ifndef TO_SIM
`include "../rv_structs.vh"
`endif

module rv_alu2
(
    input   wire                        i_clk,
    input   alu1_bus_t                  i_bus,
    output  alu2_bus_t                  o_bus
);

    logic[31:0] op1, op2;
    logic       eq, lts, ltu;
    logic[32:0] add;
    logic[31:0] xor_, or_, and_, shl;
    logic[32:0] shr;
    logic[31:0] shift_result;
    logic       cmp_result;
    logic[31:0] bits_result;
    logic       carry;
    logic       op_b_sel;
    logic[31:0] op_b;
    logic       negative;
    logic       overflow;
    alu_ctrl_t  ctrl;
    logic       store;
    logic       reg_write;
    logic[4:0]  rd;
    logic       inst_jal_jalr, inst_branch;
    logic[31:0] pc;
    logic[31:0] pc_target;
    res_src_t   res_src;
    logic[2:0]  funct3;
    logic[31:0] reg_data2;
`ifdef EXTENSION_C
    logic       compressed;
`endif

    always_ff @(posedge i_clk)
    begin
        op1 <= i_bus.op1;
        op2 <= i_bus.op2;
        ctrl <= i_bus.alu_ctrl;
        store <= i_bus.store;
        reg_write <= i_bus.reg_write;
        rd <= i_bus.rd;
        inst_jal_jalr <= i_bus.inst_jal_jalr;
        inst_branch <= i_bus.inst_branch;
        pc <= i_bus.pc;
        pc_target <= i_bus.pc_target;
        res_src <= i_bus.res_src;
        funct3 <= i_bus.funct3;
        reg_data2 <= i_bus.reg_data2;
    `ifdef EXTENSION_C
        compressed <= i_bus.compressed;
    `endif
    end

    // adder - for all (add/sub/cmp)
    assign  op_b_sel = (ctrl.arith_sub | ctrl.res_cmp);
    assign  op_b     = op_b_sel ? (~op2) : op2;
    assign  add      = op1 + op_b + { {32{1'b0}}, op_b_sel};
    assign  negative = add[31];
    assign  overflow = (op1[31] ^ op2[31]) & (op1[31] ^ add[31]);
    assign  carry    = add[32];

    assign  eq  = ctrl.cmp_inversed ^ (op1 == op2);
    assign  lts = ctrl.cmp_inversed ^ (negative ^ overflow);
    assign  ltu = ctrl.cmp_inversed ^ (!carry);

    assign  xor_ = op1 ^ op2;
    assign  or_  = op1 | op2;
    assign  and_ = op1 & op2;
    assign  shl = op1 << op2[4:0];
    assign  shr = $signed({ctrl.shift_arithmetical ? op1[31] : 1'b0, op1}) >>> op2[4:0];

    always_comb
    begin
        case (1'b1)
        ctrl.cmp_lts: cmp_result = lts;
        ctrl.cmp_ltu: cmp_result = ltu;
        default:      cmp_result = eq;
        endcase
    end

    logic   pc_select;
    assign  pc_select = /*(!fetch_bp_need) & */(inst_jal_jalr | (inst_branch & (cmp_result)));

    always_comb
    begin
        case (1'b1)
        ctrl.bits_xor: bits_result = xor_;
        ctrl.bits_or:  bits_result = or_;
        default:       bits_result = and_;
        endcase
    end

    always_comb
    begin
        case (1'b1)
        ctrl.arith_shr: shift_result = shr[31:0];
        default:        shift_result = shl;
        endcase
    end

/* verilator lint_off UNUSEDSIGNAL */
    logic   dummy;
    assign  dummy = ctrl.cmp_eq & ctrl.bits_and & ctrl.arith_shl & shr[32];
/* verilator lint_on UNUSEDSIGNAL */

    assign  o_bus.bits_result = bits_result;
    assign  o_bus.pc_select = pc_select;
    assign  o_bus.cmp_result = cmp_result;
    assign  o_bus.add = add[31:0];
    assign  o_bus.shift_result = shift_result;
    assign  o_bus.ctrl = ctrl;
    assign  o_bus.store = store;
    assign  o_bus.reg_write = reg_write;
    assign  o_bus.rd = rd;
    assign  o_bus.pc = pc;
    assign  o_bus.pc_target = pc_target;
    assign  o_bus.res_src = res_src;
    assign  o_bus.funct3 = funct3;
    assign  o_bus.reg_data2 = reg_data2;
`ifdef EXTENSION_C
    assign  o_bus.compressed = compressed;
`endif

endmodule
