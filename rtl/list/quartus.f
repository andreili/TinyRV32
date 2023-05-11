SRCS += $(RTL_DIR)/rv_top_wb.sv
SRCS += $(RTL_DIR)/tcm.sv
SRCS += $(RTL_DIR)/nic.sv
SRCS += $(RTL_DIR)/debounce.sv
SRCS += $(RTL_DIR)/../vrf/top.sv
SRCS += $(RTL_DIR)/core/rv_core.sv
SRCS += $(RTL_DIR)/core/rv_ctrl.sv
SRCS += $(RTL_DIR)/core/rv_regs.sv
SRCS += $(RTL_DIR)/core/rv_trace.sv
SRCS += $(RTL_DIR)/core/rv_fetch.sv
SRCS += $(RTL_DIR)/core/rv_fetch_addr.sv
SRCS += $(RTL_DIR)/core/rv_fetch_buf.sv
SRCS += $(RTL_DIR)/core/rv_decode.sv
SRCS += $(RTL_DIR)/core/rv_decode_comp.sv
SRCS += $(RTL_DIR)/core/rv_hazard.sv
SRCS += $(RTL_DIR)/core/rv_alu1.sv
SRCS += $(RTL_DIR)/core/rv_alu2.sv
SRCS += $(RTL_DIR)/core/rv_write.sv
SRCS += $(RTL_DIR)/core/math/add.sv
SRCS += $(RTL_DIR)/core/math/adder.sv
SRCS += $(RTL_DIR)/core/math/alu_mux.sv
SRCS += $(RTL_DIR)/core/math/bitwise.sv
SRCS += $(RTL_DIR)/core/math/muldiv.sv
SRCS += $(RTL_DIR)/core/math/pc_sel.sv
SRCS += $(RTL_DIR)/core/math/wr_mux.sv
SRCS += $(RTL_DIR)/csr/rv_csr.sv
SRCS += $(RTL_DIR)/csr/rv_csr_cntr.sv
SRCS += $(RTL_DIR)/csr/rv_csr_machine.sv
SRCS += $(RTL_DIR)/csr/rv_csr_reg.sv
SRCS += $(RTL_DIR)/lib_fpga/reg_e.sv
SRCS += $(RTL_DIR)/lib_fpga/reg_s.sv
SRCS += $(RTL_DIR)/peripheral/uart/cmsdk_wb_uart.v

# platform-depedent files
SRCS += $(PROJ_DIR)/ips/pll/pll.v
SRCS += $(PROJ_DIR)/ips/pll//pll/pll_0002.v
