		
		CODE32



		AREA myFixedAsm,CODE,READONLY
		EXPORT fixmul
		EXPORT fixmac2
		EXPORT fixmac3
		EXPORT fixlgh

		gbla		num1
		gbla		num2
		gbla		num3
		gbla		num4
		gbla		num5
		gbla		num6
		gbla		num7
		gbla		num8
		gbla		num9

num1	seta		8388608
num2	seta		4194304
num3	seta		2796202
num4	seta		2097152
num5	seta		1677721
num6	seta		1398101
num7	seta		1198372
num8	seta		1048576
num9	seta		932067


fixmul	smull		r2, r3, r0, r1;
		movs		r2, r2, lsr #23;
		adc			r0, r2, r3, lsl #9;
		mov			pc, lr

fixmac2	smull		r12, r1, r0, r1;
		
		smlal		r12, r1, r2, r3;

		movs		r12, r12, lsr #23;
		adc			r0, r12, r1, lsl #9;
		
		mov			pc, lr

fixmac3	smull		r12, r1, r0, r1;
		
		smlal		r12, r1, r2, r3;
		
		ldmia		sp, {r2,r3};
		
		smlal		r12, r1, r2, r3;
		
		movs		r12, r12, lsr #23;
		adc			r0, r12, r1, lsl #9;
		
		mov			pc, lr

fixlgh	ldr			r12, =num1
		smull		r2, r3, r12, r0		; r0=w r1=-x	y=r2,r3		
		
		smull		r12, r0, r1, r0;
		movs		r12, r12, lsr #23;
		adc			r0, r12, r0, lsl #9;
		
		
		ldr			r12, =num2
		smlal		r2, r3, r12, r0
	
		smull		r12, r0, r1, r0;
		movs		r12, r12, lsr #23;
		adc			r0, r12, r0, lsl #9;
	
		ldr			r12, =num3
		smlal		r2, r3, r12, r0
	
		smull		r12, r0, r1, r0;
		movs		r12, r12, lsr #23;
		adc			r0, r12, r0, lsl #9;
	
		ldr			r12, =num4
		smlal		r2, r3, r12, r0
	
		smull		r12, r0, r1, r0;
		movs		r12, r12, lsr #23;
		adc			r0, r12, r0, lsl #9;
	
		ldr			r12, =num5
		smlal		r2, r3, r12, r0
	
		smull		r12, r0, r1, r0;
		movs		r12, r12, lsr #23;
		adc			r0, r12, r0, lsl #9;
	
		ldr			r12, =num6
		smlal		r2, r3, r12, r0
	
		smull		r12, r0, r1, r0;
		movs		r12, r12, lsr #23;
		adc			r0, r12, r0, lsl #9;
	
		ldr			r12, =num7
		smlal		r2, r3, r12, r0
	
		smull		r12, r0, r1, r0;
		movs		r12, r12, lsr #23;
		adc			r0, r12, r0, lsl #9;
	
		ldr			r12, =num8
		smlal		r2, r3, r12, r0
	
		smull		r12, r0, r1, r0;
		movs		r12, r12, lsr #23;
		adc			r0, r12, r0, lsl #9;
	
		ldr			r12, =num9
		smlal		r2, r3, r12, r0

		movs		r2, r2, lsr #23;
		adc			r0, r2, r3, lsl #9;
		mov			pc, lr


		END

