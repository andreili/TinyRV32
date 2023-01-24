`timescale 1ps/1ps

`include "rv_defines.vh"

module rv_top_wb
#(
    parameter RESET_ADDR                = 32'h0000_0000,
    parameter INSTR_BUF_ADDR_SIZE       = 3,
    parameter EXTENSION_C               = 1,
    parameter EXTENSION_Zicsr           = 1,
    parameter EXTENSION_Zicntr          = 1,
    parameter EXTENSION_Zihpm           = 0
)
(
    input   wire                        i_clk,
    input   wire                        i_reset_n,
    //
    output  wire[31:0]                  o_wb_adr,
    output  wire[31:0]                  o_wb_dat,
    input   wire[31:0]                  i_wb_dat,
    output  wire                        o_wb_we,
    output  wire[3:0]                   o_wb_sel,
    output  wire                        o_wb_stb,
    input   wire                        i_wb_ack,
`ifdef TO_SIM
    output  wire[31:0]                  o_debug,
`endif
    output  wire                        o_wb_cyc
);

    generate
        if (!EXTENSION_Zicsr)
        begin
            if (EXTENSION_Zicntr)
                $error("Invalid configuration! Zicntr w/o Zicsr");
            if (EXTENSION_Zihpm)
                $error("Invalid configuration! Zihpm w/o Zicsr");
        end
    endgenerate

    logic       instr_req;
    logic[31:0] instr_addr;
    logic       instr_ack;
    logic[31:0] instr_data;
    logic       data_req;
    logic       data_write;
    logic[31:0] data_addr;
    logic       data_ack;
    logic[31:0] data_wdata;
    logic[31:0] data_rdata;
    logic[3:0]  data_sel;

    logic[11:0] csr_idx;
    logic[4:0]  csr_imm;
    logic       csr_imm_sel;
    logic       csr_write;
    logic       csr_set;
    logic       csr_clear;
    logic       csr_read;
    logic       csr_ebreak;
    logic[31:0] csr_pc_next;
    logic[31:0] csr_rdata;
    logic[31:0] ret_addr;
    logic       csr_to_trap;
    logic[31:0] csr_trap_pc;
    logic       csr_oread;
    logic[31:0] reg_rdata1;

    rv_core
    #(
        .RESET_ADDR                     (RESET_ADDR),
        .INSTR_BUF_ADDR_SIZE            (INSTR_BUF_ADDR_SIZE),
        .EXTENSION_C                    (EXTENSION_C),
        .EXTENSION_Zicsr                (EXTENSION_Zicsr)
    )
    u_core
    (
        .i_clk                          (i_clk),
        .i_reset_n                      (i_reset_n),
`ifdef TO_SIM
        .o_debug                        (o_debug),
`endif
        .o_csr_idx                      (csr_idx),
        .o_csr_imm                      (csr_imm),
        .o_csr_imm_sel                  (csr_imm_sel),
        .o_csr_write                    (csr_write),
        .o_csr_set                      (csr_set),
        .o_csr_clear                    (csr_clear),
        .o_csr_read                     (csr_read),
        .o_csr_ebreak                   (csr_ebreak),
        .o_csr_pc_next                  (csr_pc_next),
        .i_csr_to_trap                  (csr_to_trap),
        .i_csr_trap_pc                  (csr_trap_pc),
        .i_csr_read                     (csr_oread),
        .i_csr_ret_addr                 (ret_addr),
        .i_csr_data                     (csr_rdata),
        .o_reg_rdata1                   (reg_rdata1),
        .o_instr_req                    (instr_req),
        .o_instr_addr                   (instr_addr),
        .i_instr_ack                    (instr_ack),
        .i_instr_data                   (instr_data),
        .o_data_req                     (data_req),
        .o_data_write                   (data_write),
        .o_data_addr                    (data_addr),
        .o_data_wdata                   (data_wdata),
        .o_data_sel                     (data_sel),
        .i_data_ack                     (data_ack),
        .i_data_rdata                   (data_rdata)
    );

    generate
        if (EXTENSION_Zicsr)
        begin
            rv_csr
            #(
                .EXTENSION_C                    (EXTENSION_C),
                .EXTENSION_Zicntr               (EXTENSION_Zicntr),
                .EXTENSION_Zihpm                (EXTENSION_Zihpm)
            )
            u_st3_csr
            (
                .i_clk                          (i_clk),
                .i_reset_n                      (i_reset_n),
                .i_reg_data                     (reg_rdata1),
                .i_idx                          (csr_idx),
                .i_imm                          (csr_imm),
                .i_imm_sel                      (csr_imm_sel),
                .i_write                        (csr_write),
                .i_set                          (csr_set),
                .i_clear                        (csr_clear),
                .i_read                         (csr_read),
                .i_ebreak                       (csr_ebreak),
                .i_pc_next                      (csr_pc_next),
                .o_read                         (csr_oread),
                .o_ret_addr                     (ret_addr),
                .o_csr_to_trap                  (csr_to_trap),
                .o_trap_pc                      (csr_trap_pc),
                .o_data                         (csr_rdata)
            );
        end
        else
        begin
            /* verilator lint_off UNUSEDSIGNAL */
            logic dummy;
            /* verilator lint_on UNUSEDSIGNAL */
            assign csr_oread = '0;
            assign ret_addr = '0;
            assign csr_to_trap = '0;
            assign csr_trap_pc = '0;
            assign csr_rdata = '0;
            assign dummy = (|reg_rdata1) | (|csr_idx) | (|csr_imm) | csr_imm_sel | csr_write | csr_set
                            | csr_clear | csr_read | csr_ebreak | (|csr_pc_next);
        end
    endgenerate

    assign  instr_data = i_wb_dat;
    assign  data_rdata = i_wb_dat;
    assign  data_ack = i_wb_ack & (!instr_ack);
    assign  instr_ack = i_wb_ack & (!data_req) & instr_req;

    assign o_wb_adr = data_req ? data_addr : instr_addr;
    assign o_wb_dat = data_wdata;
    assign o_wb_we = data_req ? data_write : '0;
    assign o_wb_sel = data_req ? data_sel : '1;
    assign o_wb_stb = '1;
    assign o_wb_cyc = '1;

initial
    instr_data = '0;

endmodule
