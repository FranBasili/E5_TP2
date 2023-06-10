module latchDec(
input wire clk, 
input wire en,
input wire reset,
input wire [9:0] aluCtrl,  
input wire [31:0] imm,
input wire [5:0] selA,     
input wire [4:0] selB,
input wire [5:0] selOut,
input wire imm_en,
input wire [2:0] jmp_type,
input wire new_jmp,
input wire [8:0] lam_control,
input wire lam_new,
input wire demux_alu,

output reg [31:0] imm_,
output reg imm_en_,
output reg [9:0] aluCtrl_,
output reg [5:0] selA_,      
output reg [4:0] selB_,
output reg [5:0] selOut_,
output reg [2:0] jmp_type_,
output reg new_jmp_,
output reg [8:0] lam_control_,
output reg lam_new_,
output reg demux_alu_
);



always @(posedge clk, posedge reset) begin
	if (reset) begin
		imm_ <= 0;
		imm_en_ <= 0; 
		aluCtrl_ <= 0;
		selA_ <= 0;
		selB_ <= 0;
		selOut_ <= 0;
		jmp_type_ <= 0;
		new_jmp_ <= 0;
		lam_control_ <= 0;
		lam_new_ <= 0;
		demux_alu_ <= 0;
	end
	else if (en) begin
		imm_ <= imm;
		imm_en_ <= imm_en; 
		aluCtrl_ <= aluCtrl;
		selA_ <= selA;
		selB_ <= selB;
		selOut_ <= selOut;
		jmp_type_ <= jmp_type;
		new_jmp_ <= new_jmp;
		lam_control_ <= lam_control;
		lam_new_ <= lam_new;
		demux_alu_ <= demux_alu;
    end
end

endmodule
