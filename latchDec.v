module latchDec(
input wire clk, 
input wire en,
input wire reset,				// reset sincronico con clk
input wire [9:0] aluCtrl,  
input wire [31:0] imm,
input wire [5:0] selA,     
input wire [4:0] selB,
input wire [5:0] selOut,
input wire imm_en,
input wire [2:0] jmp_type,
input wire [31:0] jmp_imm,
input wire new_jmp,
input wire [5:0] jal_rs,
input wire lam_new,
input wire lam_rw,
input wire [2:0] lam_type,
input wire [4:0] lam_rs,
input wire [4:0] lam_sel_out,

output reg [31:0] imm_,
output reg imm_en_,
output reg [9:0] aluCtrl_,
output reg [5:0] selA_,      
output reg [4:0] selB_,
output reg [5:0] selOut_,
output reg [2:0] jmp_type_,
output reg [31:0] jmp_imm_,
output reg new_jmp_,
output reg [5:0] jal_rs_,
output reg lam_new_,
output reg lam_rw_,
output reg [2:0] lam_type_,
output reg [4:0] lam_rs_,
output reg [4:0] lam_sel_out_
);



always @(posedge clk) begin
	if (reset) begin
		imm_ <= 0;
		imm_en_ <= 0; 
		aluCtrl_ <= 0;
		selA_ <= 0;
		selB_ <= 0;
		selOut_ <= 0;
		jmp_type_ <= 0;
		jmp_imm_ <= 0;
		new_jmp_ <= 0;
		jal_rs_ <= 0;
		lam_new_ <= 0;
		lam_rw_ <= 0;
    	lam_type_ <= 0;
    	lam_rs_ <= 0;
    	lam_sel_out_ <= 0;
	end
	else if (en) begin
		imm_ <= imm;
		imm_en_ <= imm_en; 
		aluCtrl_ <= aluCtrl;
		selA_ <= selA;
		selB_ <= selB;
		selOut_ <= selOut;
		jmp_type_ <= jmp_type;
		jmp_imm_ <= jmp_imm;
		new_jmp_ <= new_jmp;
		jal_rs_ <= jal_rs;
		lam_new_ <= lam_new;
		lam_rw_ <= lam_rw;
    	lam_type_ <= lam_type;
    	lam_rs_ <= lam_rs;
    	lam_sel_out_ <= lam_sel_out;

    end
end

endmodule
