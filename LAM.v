`define LB	3'b000
`define LH  3'b001
`define LW  3'b010
`define LBU 3'b100
`define LHU 3'b101

`define SB  3'b000
`define SH  3'b001
`define SW  3'b010


module LAM(
	input wire clk,    
	input wire reset,
	input wire lam_new,             // Si es una instruccion de Load o Store = 1 o nada = 0
	input wire read_write,          // 0 si es lectura, 1 si es escritura
	input wire [5:0] sel_out,       // Bits de seleccion de bus de salida, para instruccion de LOAD
	input wire [5:0] rs2,           // Para Store, es de donde se saca la data
	input wire [2:0] lam_type,      // Para distinguir entre los distintos Load y Store 

	input wire [31:0] data_from_BR,
	input wire [31:0] data_from_MD,

	output wire read_write_lam,
	output reg [5:0] sel_out_lam,
	output reg [5:0] rs2_lam,
	output reg [31:0] data_2_BR,
	output reg [31:0] data_2_MD,
	output reg clk_latch_address
);

	reg shifter_lam_new[2];
	reg shifter_read_write[2];
	reg [5:0] shifter_sel_out[2];
	reg [5:0] shifter_rs2[2];
	reg [2:0] shifter_lam_type[2];

	reg negEn = 0;

	reg clk_in_en_shift;
	reg memory_ready = 0;

	// Registro que funciona por flanco negativo, guarda el si hay Lam que se corre en LAM
	always @(negedge clk)begin
		negEn <= shifter_lam_new[1];	
	end

	reg memory_ready_negedge = 0;
	// El registro que tiene medio ciclo de retardo con la signal de memory_ready
	always @(negedge clk)begin
		memory_ready_negedge <= memory_ready;
	end

	// La logica combinacional para decidir cuando se shiftea o no el SR
	always @(*)begin
		clk_in_en_shift = 0; 
		if(negEn == 0 || memory_ready_negedge == 1)begin
			clk_in_en_shift = 1;
		end
	end

	// Latcheo el SR
	always @(posedge clk)begin
		if(reset == 1)begin
			shifter_lam_new[0] <= 0;
			shifter_read_write[0] <= 0;
			shifter_sel_out[0] <= 0;
			shifter_rs2[0] <= 0;
			shifter_lam_type[0] <= 0;
		end
		if(clk_in_en_shift == 1)begin
			shifter_lam_new[0] <= lam_new;
			shifter_read_write[0] <= read_write;
			shifter_sel_out[0] <= sel_out;
			shifter_rs2[0] <= rs2;
			shifter_lam_type[0] <= lam_type;

			shifter_lam_new[1] <= shifter_lam_new[0];
			shifter_read_write[1] <= shifter_read_write[0];
			shifter_sel_out[1] <= shifter_sel_out[0];
			shifter_rs2[1] <= shifter_rs2[0];
			shifter_lam_type[1] <= shifter_lam_type[0];
		end
	end

	// Fabrico el contador
	`define NMAX 4
	reg [2:0] counter = 0;
	reg running = 0;
	always @(posedge clk)begin
		memory_ready = 0;
		//counter = 0;
		running = 0;
		if(counter == 0)begin
			if (negEn == 1) begin
				counter = 1;
				running = 1;
			end
		end
		else if(counter > 0 && counter < `NMAX-1)begin
			counter = counter + 3'b1;
			running = 1;
		end
		else if(counter == `NMAX-1)begin
			counter = `NMAX;
			running = 1;
			memory_ready = 1;
		end
		else begin
			counter = 0;
			running = 0;
			memory_ready = 0;
		end
	end

	// Habilito o no el latch por flanco de bajada del address 
	always @(*)begin
		clk_latch_address = 0;
		if(running == 0)begin
			clk_latch_address = clk;
		end
	end

	assign read_write_lam = shifter_read_write[1];

	always @(*)begin
		rs2_lam = 0;
		sel_out_lam = 0;
		data_2_BR = 0;
		data_2_MD = 0;
		if(shifter_lam_new[1] == 1 && shifter_read_write[1] == 0 && memory_ready == 1)begin
			sel_out_lam = shifter_sel_out[1];
			case(shifter_lam_type[1])
			`LB:begin
				data_2_BR = { {24{data_from_MD[7]}}, data_from_MD[7:0]};
			end
			`LH:begin
				data_2_BR = { {16{data_from_MD[7]}}, data_from_MD[15:0]};
			end
			`LW:begin
				data_2_BR = data_from_MD[31:0];
			end
			`LBU:begin
				data_2_BR = data_from_MD[7:0];
			end
			`LHU:begin
				data_2_BR = data_from_MD[15:0];
			end
			default: begin
			end
			endcase

		end
		else if(shifter_lam_new[1] == 1 && shifter_read_write[1] == 1)begin
			rs2_lam = shifter_rs2[1];
			case(shifter_lam_type[1])
			`SB:begin
				data_2_MD = { 24'b0, data_from_MD[7:0]};
			end
			`SH:begin
				data_2_MD = { 16'b0, data_from_MD[15:0]};
			end
			`SW:begin
				data_2_MD = data_from_MD;
			end
			default: begin
			end
			endcase
		end
	end


endmodule