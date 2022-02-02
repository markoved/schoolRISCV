`include "zbb.vh"

module zbb (
    input [31:0] din_rs1,
    input [31:0] din_rs2,
    input [6:0]  cmdOp,
    input [2:0]  cmdF3,
    input [6:0]  cmdF7,
    input [11:0] immI,
    output reg [31:0] dout_rd,
    output reg isZbbInstr,
    output reg regWrite
);
    wire [31:0] andn = din_rs1 & ~din_rs2;
    wire [31:0] orn  = din_rs1 | ~din_rs2;
    wire [31:0] xnor_ = ~din_rs1 ^ din_rs2;

    reg [31:0] clz;
    reg clzOneMet;
    reg [31:0] ctz;
    reg ctzOneMet;

    integer i;

    always @ (*) begin
        isZbbInstr = 1'b1;
        regWrite   = 1'b1;
        clzOneMet  = 1'b0;
        ctzOneMet  = 1'b0;
    
        clz = 32'b0;
        for (i = 31; i >= 0; i = i - 1)
            if (!clzOneMet & !din_rs1[i]) clz = clz + 1;
            else clzOneMet = 1'b1;
        
        ctz = 32'b0;
        for (i = 0; i < 32; i = i + 1)
            if (!ctzOneMet & !din_rs1[i]) ctz = ctz + 1;
            else ctzOneMet = 1'b1;

        casez( {cmdF7, cmdF3, cmdOp} )
            { `ZBBF7_ANDN, `ZBBF3_ANDN, `ZBBOP_ANDN } : dout_rd = andn;
            { `ZBBF7_ORN,  `ZBBF3_ORN,  `ZBBOP_ORN  } : dout_rd = orn;
            { `ZBBF7_XNOR, `ZBBF3_XNOR, `ZBBOP_XNOR } : dout_rd = xnor_;
            default : begin isZbbInstr = 1'b0; regWrite = 1'b0; end
        endcase

        casez( {immI, cmdF3, cmdOp} )
            { `ZBBIMMI_CLZ, `ZBBF3_CLZ, `ZBBOP_CLZ } : dout_rd = clz;
            { `ZBBIMMI_CTZ, `ZBBF3_CTZ, `ZBBOP_CTZ } : dout_rd = ctz;
            default : begin isZbbInstr = 1'b0; regWrite = 1'b0; end
        endcase
    end

endmodule
