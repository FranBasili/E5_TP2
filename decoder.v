// `define ALU_ZERO	4'b0000     // 0x0000
// `define ALU_ONE		4'b0001
// `define ALU_A		4'b0010 
// `define ALU_B		4'b0011
// `define ALU_INC		4'b0100
// `define ALU_DEC		4'b0101
// `define ALU_ADD		4'b1000     // A + B
// `define ALU_SUB		4'b1001		// A - B
// `define ALU_SHL		4'b1010
// `define ALU_SHR		4'b1011

`define LUI_U_Type      7'b0110111   
`define AUIPC_U_Type    7'b0010111   
`define I_Type          7'b1100111  
`define J_Type          7'b1101111
`define R_Type          7'b0110011  
`define S_Type          7'b0100011  
`define SH_R_Type       7'b0010011  
`define B_Type          7'b1100011


module decode(
    input[31:0] instruction,
    
    output reg [9:0] aluCtrl,   // funct7 + funct3
	output reg [31:0] imm,
    output reg [5:0] selA,      // Este tiene 5 porque incluye al PC
    output reg [4:0] selB,
    output reg [5:0] selOut,
	//output reg [?:0]jmp_ctrl,
);

	
	// wire [7:0]Imm = code[7:0];
	// wire [3:0]Save = code[3:0];
	// wire [1:0]B = code[5:4];
	// wire [1:0]A = code[7:6];
	// wire [1:0]Op = code[9:8];
	 
	always @(instruction)
	begin
        case (instruction[6:0])
            `R_Type: begin
                selA = instruction[19:15]; selB = instruction[24:20]; selOut = instruction[11:7]; 
                aluCtrl = [ instruction[31:25], instruction [11:7] ]; 
            end
            
			`SH_Type: begin
                selA = instruction[19:15]; imm = instruction[24:20]; selOut = instruction[11:7]; 
                aluCtrl = [ instruction[31:25], instruction [11:7] ]; 
            end

            `I_Type: begin  //Ver, es media turbia
                selA = instruction[19:15]; inm = instruction[31:20]; selOut = instruction[11:7]; 
                aluCtrl = instruction [11:7];   // JALR (Jump And Link Register) salto a subrutina
            end  

            `S_Type: begin
                selA = instruction[19:15]; selB = instruction[24:20]; // ESTO VA A MEMORIA, HAY QUE AVISAR DE ALGUNA FORMA 
                imm = [ instruction[31:25], instruction [11:7] ]; //aluCtrl = OPCODE_ALU_SUMA_IMM 
            end

            `B_Type: begin
                selA = instruction[19:15]; selB = instruction[24:20];
                imm = [ instruction[31], instruction[7], instruction[30:25], instruction [11:8] ]; //aluCtrl = OPCODE_ALU_RESTA;
				//jmp_ctrl = []; 
            end
          
            `LUI_U_Type: begin
                inm = instruction[31:12]; selOut = instruction[11:7];
            end

            `AUIPC_U_Type: begin
                inm = instruction[31:12]; selOut = instruction[11:7];
            end
        endcase

		casex (instruction)

			/*
			8'h01:  begin selA=0; selB=1; alu=ALU_ADD; save0=0; save1=0; save2=1; end //REG1 = REG0 
			8'h02:  begin selA=0; selB=1; alu=ALU_SUB; save0=0; save1=0; save2=1; end //REG2 = REG0
			8'h03:  begin selA=0; selB=0; alu=ALU_INC; save0=1; save1=0; save2=0; end //REG0 = REG0 + REG1
			8'h04:  begin selA=1; selB=0; alu=ALU_INC; save0=0; save1=1; save2=0; end //REG0 = REG1 + REG2
			*/
				
			
			12'b0100xxxxxxxx: begin selA=0; selB=0; alu=`ALU_A; save=4'b0001; loadI_A=1; end
			12'b0101xxxxxxxx: begin selA=0; selB=0; alu=`ALU_A; save=4'b0010; loadI_A=1; end
			12'b0110xxxxxxxx: begin selA=0; selB=0; alu=`ALU_A; save=4'b0100; loadI_A=1; end
			12'b0111xxxxxxxx: begin selA=0; selB=0; alu=`ALU_A; save=4'b1000; loadI_A=1; end
			
			12'b00xxxxxxxxxx: begin selA=A; selB=B; alu=`ALU_ADD + Op; save=Save; loadI_A=0; end
		endcase
	end

	assign nextPC = q;
 
endmodule