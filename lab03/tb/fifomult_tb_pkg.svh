/******************************************************************************
 * (C) Copyright 2024 AGH University All Rights Reserved
 *
 * MODULE:    tinyalu_tb_pkg
 * DEVICE:
 * PROJECT:
 * AUTHOR:    szczygie
 * DATE:      2024 12:20:30
 *
 *******************************************************************************/

package fifomult_tb_pkg;


typedef enum bit {
    OK,
    NOT_OK
} parity_t;
	
typedef struct {
	bit signed [15:0] A;
	bit A_parity;
	bit signed [15:0] B;
	bit B_parity;
	bit signed [31:0] exp;
	parity_t A_parity_chk;
	parity_t B_parity_chk;
} st_data_in_packet_t;

endpackage
