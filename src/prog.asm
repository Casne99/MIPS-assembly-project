		.data
sleeptime:	.word 50 #In millisecondi 
color:		.word 0x8A33FF
disp_width:	.word 256
disp_height:	.word 256
unit_width:	.word 8	  #Larghezza unità
unit_height:	.word 8	  #Altezza unità
addr:		.word 0x10010000 #Indirizzo del display


S0:	.asciiz "Left pyramid code: "
S1:	.asciiz "Right pyramid code: "
S3:	.asciiz "Height: "
S4:	.asciiz "Not valid input"


	.text
	.globl main
	
#Per prima cosa calcolo il numero di unità per riga e per colonna
#Al termine di questo primo step avrò $s5 = unità per riga, $s4 = unità per colonna
#Il numero di unità per riga lo ottengo dividendo la larghezza del display per la larghezza di ogni singola unità
#Procedo analogamente per il numero di unità per colonna

main:

	la $t0 disp_width
	la $t1 disp_height
	lw $t0 0($t0)		#$t0 = disp_width
	lw $t1 0($t1)		#$t1 = disp_height	
	la $s3 sleeptime
	lw $s3 0($s3)
	
	la $t2 unit_width
	la $t3 unit_height
	lw $t2 0($t2)		#$t2 = unit_width
	lw $t3 0($t3)		#$t3 = unit_height
	
	div $t0 $t2
	mflo $s5
	
	div $t1 $t3
	mflo $s4
	
	la $a0 S3
	addi $v0 $0 4
	syscall
	
	addi $v0 $0 5    # #
	syscall		 # $s2 = altezza inserita da tastiera
	add $s2 $0 $v0	 # #				  
	
	add $a0 $0 $s2   # #					
	add $a1 $0 $s5   # Passaggio dei parametri per check
	add $a2 $0 $s4   # #
	jal check

	
	beq $v0 1 input_non_valido
	beq $v0 2 termina
	
#Sarà chiesto il codice (0 o 1) da associare ad ognuna delle due semi_piramidi
#Il codice associato alla semi-piramide sinistra sarà salvato in $s0
#Il codice associato alla semi-piramide destra sarà salvato in $s1

	la $a0 S0
	addi $v0 $0 4
	syscall	

	addi $v0 $0 5
	syscall
	add $s0 $v0 $0  #$s0 = codice piramide sinistra
	add $a0 $s0 $0
	jal check_code
	
	beq $v0 0 input_non_valido
	
	add $a0 $s2 $0
	add $a1 $s0 $0
	jal area
	add $s6 $0 $v0
	
	la $a0 S1
	addi $v0 $0 4
	syscall	

	addi $v0 $0 5
	syscall
	add $s1 $v0 $0  #$s1 = codice piramide destra
	add $a0 $s1 $0
	jal check_code

	
	beq $v0 0 input_non_valido
	
	add $a0 $s2 $0
	add $a1 $s1 $0
	jal area
	add $s6 $s6 $v0   # in $s6 salvo il numero di bytes allocati
	
	addi $v0 $0 9
	add $a0 $0 $s6
	syscall
	add $s3 $v0 $0  # in $s3 salvo il base address della memoria dinamica allocata
	
	la $s7 color
	lw $s7 0($s7)  # $s7 = colore
	
	blt $s2 3 special

	la $a0 addr	
	lw $a0 0($a0)
	mul $a1 $s5 4
	add $a2 $s4 $0
	jal left_starting_address	

	add $a0 $v0 $0	#
	mul $a1 $s5 4	# PASSAGGIO PARAMETRI
	add $a2 $0 $s3	#  per le procedure empty/full_left
	add $a3 $0 $s2	#	
	
	beq $s0 0 left_case0
	beq $s0 1 left_case1
	
end_left:
	add $a0 $s2 $0
	add $a1 $s0 $0
	jal area
	mul $t0 $v0 4	#Sommo al base address della memoria dinamica allocata un offset per
	add $t0 $s3 $t0	#individuare il punto di partenza per la scrittura degli indirizzi della seconda piramide
	subi $sp $sp 4	#
	sw $t0 0($sp)	#
	
	la $a0 addr	
	lw $a0 0($a0)
	mul $a1 $s5 4
	add $a2 $s4 $0
	jal right_starting_address
	
	add $a0 $v0 $0  #
	mul $a1 $s5 4	# PASSAGGIO PARAMETRI per le procedure empty/full_right
	add $a3 $0 $s2	#
	
	lw $a2 0($sp)
	addi $sp $sp 4

	beq $s1 0 right_case0
	beq $s1 1 right_case1
	
left_case0:
	jal empty_left
	j end_left
	
left_case1:
	jal full_left
	j end_left
	
right_case0:
	jal empty_right
	add $a0 $s3 $0
	add $a1 $s7 $0
	add $a2 $s6 $0
	
	la $a3 sleeptime
	lw $a3 0($a3)
	jal disegna
	j termina
	
right_case1:
	jal full_right
	add $a0 $s3 $0
	add $a1 $s7 $0
	add $a2 $s6 $0
	
	la $a3 sleeptime
	lw $a3 0($a3)
	jal disegna
	j termina
	
#disegna()
#Procedura che visita gli indirizzi salvati nello heap e li colora
#Si aspetta in $a0 il base address dell' area di memoria dinamica allocata
#	    in $a1 il colore
#	    in $a2 il numero di bytes allocati
#	    in $a3 lo sleeptime
disegna:
	beq $a2 0 end
	lw $t0 0($a0)
	sw $a1 0($t0)
	add $t0 $a0 $0
	add $a0 $a3 $0
	addi $v0 $0 32
	syscall
	add $a0 $t0 $0
	addi $a0 $a0 4
	subi $a2 $a2 1
	j disegna
	
termina:  
	addi $v0 $0 10
	syscall
	
input_non_valido:
	la $a0 S4
	addi $v0 $0 4
	syscall
	j termina
	
	
#Procedura check
#Ritorna 0 se la piramide simmetrica di altezza n è stampabile su un display di una determinata grandezza
#Ritorna 1 in caso contrario
#Ritorna 2 se altezza == 0
#Considerando che due colonne di bit saranno utilizzate per distanziare le due "semi-piramidi" un prototipo di funzione è:
#int check(int height, int pixel_per_column, int pixel_per_row) {
#	if (height == 0) {
#		return 2
#	}
#	if (height > pixel_per_row/2 - 1 || height > pixel_per_column || height < 0) {
#		return 0
#	}
#	return 1
#}
#La procedura si aspetta in $a0 il valore dell' altezza
#			 in $a1 il valore pixel_per_row
#			 in $a2 il valore pixel_per_column
	
check:
	beq $a0 0 due
	div $a1 $a1 2
	subi $a1 $a1 1
	bgt $a0 $a1 non_valido
	bgt $a0 $a2 non_valido
	blt $a0 0 non_valido
	j zero

non_valido:
	addi $v0 $0 1
	j end
	
zero:
	add $v0 $0 $0
	j end
	
due:
	addi $v0 $0 2

end:
	jr $ra
	
	
#empty_left(int address, int row_size, int height)
#Stampa una semi-piramide vuota di altezza height su un display associato all' indirizzo address
#La procedura si aspetta in $a0 l' indirizzo di partenza del disegno
#			 in $a1 la dimensione di una riga del display in bytes
#			 in $a2 l' indirizzo base della memoria dinamica allocata
#			 in $a3 l' altezza della semi-piramide (height)

empty_left:

	add $t0 $0 $a2
	addi $t5 $0 1  #Uso $t5 come contatore nei loop
	
#loop1 individua il cateto verticale
#loop2 individua l' ipotenusa
#loop3 individua il cateto orizzontale
#$t5 è il contatore dei cicli
#$t0 tiene conto dell' indirizzo di salvataggio all'interno della memoria dinamicamente allocata
	
loop1a:
	beq $t5 $a3 loop2a_init
	sw $a0 0($t0)
	addi $t5 $t5 1			 
	sub $a0 $a0 $a1			
	addi $t0 $t0 4		       
	j loop1a		      
	
loop2a_init:
	sw $a0 0($t0)
	addi $t0 $t0 4
	addi $t5 $0 1
	add $a0 $a0 $a1	
	subi $a0 $a0 4		
	subi $a3 $a3 1
loop2a:
	beq $t5 $a3 loop3a_init
	sw $a0 0($t0)
	addi $t5 $t5 1
	add $a0 $a0 $a1
	subi $a0 $a0 4
	addi $t0 $t0 4
	j loop2a
	
loop3a_init:
	sw $a0 0($t0)
	addi $t0 $t0 4
	addi $t5 $0 1
	addi $a0 $a0 4
	subi $a3 $a3 1
loop3a:
	beq $t5 $a3 loop3a_end
	sw $a0 0($t0)
	addi $t5 $t5 1
	addi $a0 $a0 4
	addi $t0 $t0 4
	j loop3a
loop3a_end:
	sw $a0 0($t0)
	j end
	
#full_left(int address, int row_size, int height)
#Stampa una semi-piramide piena di altezza height su un display associato all' indirizzo address
#La procedura si aspetta in $a0 l' indirizzo di partenza del disegno
#			 in $a1 la dimensione di una riga del display in bytes
#			 in $a2 l'indirizzo base della memoria dinamica allocata + offset
#			 in $a3 l' altezza della semi-piramide (height)

full_left:
	
	add $t0 $0 $a2
	
	addi $t2 $0 0	# $t2 è il contatore del ciclo interno
	addi $t1 $0 0	# $t1 è il contatore del ciclo esterno
	add $t5 $a0 $0	# 
	add $t3 $0 $a3	# $t3 contiene il valore dell' altezza ($a3 lo faccio variare)
	
loop1b:   ### CICLO INTERNO ###

	beq $t2 $t3 loop2b
	addi $t2 $t2 1
	sw $a0 0($t0)
	addi $t0 $t0 4
	sub $a0 $a0 $a1
	j loop1b
	
	
loop2b:   ### CICLO ESTERNO ###
	
	add $t2 $0 $0
	addi $t1 $t1 1
	subi $t5 $t5 4
	add $a0 $0 $t5
	subi $t3 $t3 1
	beq $t1 $a3 end
	j loop1b
	
#empty_right
#La procedura si aspetta in $a0 l' indirizzo di partenza del disegno
#			 in $a1 la dimensione di una riga del display in bytes
#			 in $a2 l' indirizzo base della memoria dinamica allocata + offset
#			 in $a3 l' altezza della semi-piramide (height)
	
empty_right:
	add $t0 $0 $a2
	addi $t5 $0 1  #Uso $t5 come contatore nei loop
	
loop1c:
	beq $t5 $a3 loop2c_init
	sw $a0 0($t0)
	addi $t5 $t5 1
	sub $a0 $a0 $a1
	addi $t0 $t0 4
	j loop1c
	
loop2c_init:
	sw $a0 0($t0)
	addi $t0 $t0 4
	addi $t5 $0 1
	add $a0 $a0 $a1
	addi $a0 $a0 4
	subi $a3 $a3 1
loop2c:
	beq $t5 $a3 loop3c_init
	sw $a0 0($t0)
	addi $t5 $t5 1
	add $a0 $a0 $a1
	addi $a0 $a0 4
	addi $t0 $t0 4
	j loop2c
	
loop3c_init:
	sw $a0 0($t0)
	addi $t0 $t0 4
	addi $t5 $0 1
	subi $a0 $a0 4
	subi $a3 $a3 1
loop3c:
	beq $t5 $a3 loop3c_end
	sw $a0 0($t0)
	addi $t5 $t5 1
	subi $a0 $a0 4
	addi $t0 $t0 4
	j loop3c
loop3c_end:
	sw $a0 0($t0)
	j end
	
#full_right()
#Come full_left stampa una piramide piena ma nella metà destra del bitmap display
full_right:
	add $t0 $0 $a2
	
	addi $t2 $0 0
	addi $t1 $0 0
	add $t5 $a0 $0
	add $t3 $0 $a3
	
loop1d:   ### CICLO INTERNO ###

	beq $t2 $t3 loop2d
	addi $t2 $t2 1
	sw $a0 0($t0)
	addi $t0 $t0 4
	sub $a0 $a0 $a1
	j loop1d
	
	
loop2d:   ### CICLO ESTERNO ###
	
	add $t2 $0 $0
	addi $t1 $t1 1
	addi $t5 $t5 4
	add $a0 $0 $t5
	subi $t3 $t3 1
	beq $t1 $a3 end
	j loop1d
	
#int left_starting_address (int base_address, int row_size, int pixel_per_column) {
#	return base_address + (pixel_per_column - 1) * row_size + (row_size/2) - 8
#}
#Ritorna l' indirizzo corrispondente al pixel che ospiterà l' angolo rettangolo della piramide sinistra
#La procedura si aspetta in $a0 il base address del display
#			 in $a1 la dimensione di una riga in bytes
#			 in $a2 il numero di pixel per colonna
left_starting_address:
	subi $a2 $a2 1  
	mul $t6 $a2 $a1  	
	add $a0 $a0 $t6	  
	
	div $t6 $a1 2   
	subi $t6 $t6 8   
	add $v0 $a0 $t6  
	jr $ra
	
#Le due semi-piramidi sono distanziate sempre di due unità (per come il programma è strutturato)
#Per calcolare l' indirizzo dal quale iniziare il disegno della semi-piramide destra posso usare l' indirizzo di partenza
#per la semi-piramide sinistra e sommare 12
#int right_starting_address(int base_address, int row_size, int pixel_per_column) {
#	return left_starting_address(int base_address, int row_size, int pixel_per_column) + 12
#}
right_starting_address:
	subi $sp $sp 4
	sw $ra 0($sp)
	
	jal left_starting_address
	lw $ra 0($sp)
	addi $sp $sp 4
	
	addi $v0 $v0 12
	jr $ra
	
#int check_code(int a) {
#	if (a == 0 || a == 1) {
#		return 1
#	}
#	return 0
#}
#Verifica la correttezza dei codici associati alle semi-piramidi
check_code:
	beq $a0 0 valid
	beq $a0 1 valid
	
not_valid:
	addi $v0 $0 0
	jr $ra

valid:
	addi $v0 $0 1
	jr $ra

#int area(int h, int code) {
#	if (h == 1) {
#		return 1
#	} else if (h == 2) {
#		return 3
#	} else {
#		int sum = 0
#		if (code == 0) {
#			return h + (h-1) + (h-2)
#		} else if (code == 1) {
#			while (h != 0) {
#				sum += h
#				h--
#			}
#			return sum
#		}	
#}	
#Si aspetta in $a0 il valore dell'altezza
#	    in $a1 il codice di stampa (0=vuota, 1=piena)
#Ritorna il numero di unità che una piramide di altezza "h" con codice "code" occuperà
area:
	beq $a0 1 limite1				
	add $v0 $0 $0		
	addi $t0 $0 0		
	beq $a1 0 vuota		
piena:
	beq $a0 0 end
	add $v0 $v0 $a0
	subi $a0 $a0 1
	j piena
vuota:
	beq $t0 3 end
	add $v0 $v0 $a0
	subi $a0 $a0 1
	addi $t0 $t0 1
	j vuota
limite1:
	addi $v0 $0 1
	j end
	
#Special
#Parte di codice (non procedura) che si occupa di alcuni casi particolari (altezza == 1 || altezza == 2)
#In ognuno di questi due casi si ha lo stesso risultato stampato sul display indipendentemente dal codice di stampa
#In questa parte del programma vengono manualmente caricati i singoli indirizzi delle unità in memoria
#Al termine del caricamento si invoca la procedura disegna
special:
	la $a0 addr
	lw $a0 0($a0)
	mul $a1 $s5 4
	add $a2 $s4 $0
	jal left_starting_address
	
	add $a0 $v0 $0
	beq $s2 1 speciale1
	sw $a0 0($s3)
	mul $t0 $s5 4
	sub $a0 $a0 $t0
	sw $a0 4($s3)
	add $a0 $a0 $t0
	subi $a0 $a0 4
	sw $a0 8($s3)
	addi $a0 $a0 16
	sw $a0 12($s3)
	addi $a0 $a0 4
	sw $a0 16($s3)
	sub $a0 $a0 $t0
	subi $a0 $a0 4
	sw $a0 20($s3)
	
	add $a0 $s3 $0
	add $a1 $s7 $0
	add $a2 $s6 $0
	la $a3 sleeptime
	lw $a3 0($a3)
	jal disegna
	j termina
	
speciale1:
	sw $a0 0($s3)
	addi $a0 $a0 12
	sw $a0 4($s3)
	
	add $a0 $s3 $0
	add $a1 $s7 $0
	add $a2 $s6 $0
	la $a3 sleeptime
	lw $a3 0($a3)
	jal disegna
	j termina
