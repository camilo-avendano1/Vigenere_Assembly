.data
alfabeto: .asciiz " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
archivoEntrada: .asciiz "input.txt"
archivoCodificado: .asciiz "criptogram.txt"
archivoDecodificado: .asciiz "decoded.txt"
archivoPalabras: .space 1024
mensajeParaClave: .asciiz "Inserta la clave para la encriptación: "
clave: .space 20
nuevoArchivoPalabras: .space 1024 
textoFin: .asciiz "¡¡¡El programa ha finalizado exitosamente!!!"

.text
principal:
    jal obtenerClaveEncriptacion

    la $a0, archivoEntrada     	
    jal abrirArchivo
    jal leerArchivo
    jal cerrarArchivo

    la $a0, archivoPalabras           # Dirección del texto a encriptar
    la $a1, clave                    # Dirección de la clave
    la $a2, alfabeto                 # Dirección del alfabeto
    la $a3, nuevoArchivoPalabras     # Dirección del buffer donde estará el texto encriptado
    li $t0, 0                        # Índice actual sobre el contenido del documento
    li $t1, 0                        # Bandera para encriptar
    li $t2, 0                        # Índice actual sobre la clave
    li $t6, 95                       # Cantidad de caracteres en el alfabeto
    jal iterarSobreContenidoArchivo
    
    # Escribir texto encriptado en el archivo
    la $a0, archivoCodificado     	
    jal escribirTexto               
    jal cerrarArchivo               

    # Leer archivo encriptado
    la $a0, archivoCodificado     	
    jal abrirArchivo                
    jal leerArchivo                
    jal cerrarArchivo
    
    # Desencriptar texto
    la $a0, archivoPalabras           # Dirección del texto encriptado
    la $a1, clave                    # Dirección de la clave
    la $a2, alfabeto                 # Dirección del alfabeto
    la $a3, nuevoArchivoPalabras     # Dirección del buffer donde estará el texto desencriptado
    li $t0, 0                        # Índice actual sobre el contenido del documento
    li $t1, 1                        # Bandera para descifrar
    li $t2, 0                        # Índice actual sobre la clave
    li $t6, 95                       # Cantidad de caracteres en el alfabeto
    jal iterarSobreContenidoArchivo
    
    # Escribir texto decodificado
    la $a0, archivoDecodificado     	
    jal escribirTexto               
    jal cerrarArchivo               

    # Mostrar mensaje de finalización exitosa
    li $v0, 4                   
    la $a0, textoFin           
    syscall

    # Finalizar el programa
    li $v0, 10                  
    syscall

# Función para solicitar la clave de encriptación al usuario
obtenerClaveEncriptacion:
    li $v0, 4           
    la $a0, mensajeParaClave   
    syscall            
    li $v0, 8           
    la $a0, clave   
    li $a1, 20          
    syscall             
    jr $ra              

# Función para abrir un archivo
abrirArchivo:
    li $v0,13           	
    li $a1,0           	    
    syscall
    move $s0,$v0        	
    jr $ra

# Función para leer un archivo
leerArchivo:
    li $v0, 14		
    move $a0,$s0		
    la $a1,archivoPalabras  	
    la $a2,1024		
    syscall
    jr $ra

# Función para iterar sobre el contenido del archivo
iterarSobreContenidoArchivo:
    lb $t3, 0($a0)
    beqz $t3, retornoFuncion

    lb $t4, 0($a1)
    beqz $t4, reiniciarClave

    beq $t1, 0, encriptarCaracter
    beq $t1, 1, desencriptarCaracter

reiniciarClave:
    li $t2, 0
    j iterarSobreContenidoArchivo

encriptarCaracter:
    subi $t5, $t3, 32
    add $t5, $t5, $t4
    subi $t5, $t5, 32
    j nuevoCaracter

desencriptarCaracter:
    sub $t5, $t3, $t4
    bltz $t5, indicePositivo
    j nuevoCaracter

indicePositivo:
    addi $t5, $t5, 95

nuevoCaracter:
    div $t5, $t6
    mfhi $t5

    la $a2, alfabeto
    add $a2, $a2, $t5
    lb $t5, 0($a2)

    la $a3, nuevoArchivoPalabras
    add $a3, $a3, $t0

    bge $t3, 32, caracterNormal
    bge $t3, 9, caracterEspecial

caracterNormal:
    sb $t5, ($a3)
    j siguienteCaracter

caracterEspecial:
    sb $t3, ($a3)
    subi $t2, $t2, 1
    j siguienteCaracter

siguienteCaracter:
    addi $a0, $a0, 1
    addi $t2, $t2, 1
    addi $t0, $t0, 1

    addi $sp, $sp, -4
    sw $a1, 0($sp)

    add $a1, $a1, $t2
    lb $t4, 0($a1)

    lw $a1, 0($sp)
    addi $sp, $sp, 4

    beq $t4, 10, desbordamientoClave
    beq $t4, 13, desbordamientoClave
    beqz $t4, desbordamientoClave

    j iterarSobreContenidoArchivo

desbordamientoClave:
    li $t2, 0
    j iterarSobreContenidoArchivo

retornoFuncion:
    jr $ra

# Función para escribir en un archivo
escribirTexto:
    li $v0, 13           	
    li $a1, 1           	
    syscall
    move $s0, $v0        	
    
    li $v0, 15			
    move $a0, $s0		
    la $a1, nuevoArchivoPalabras		
    move $a2, $t0		
    syscall
    
    jr $ra
    
# Función para cerrar un archivo
cerrarArchivo:
    li $v0, 16         		
    move $a0, $s0      		
    syscall
    
    jr $ra
