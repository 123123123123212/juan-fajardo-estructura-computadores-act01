# Laboratorio: Estructura de Computadores
# Actividad: Optimización de Pipeline en Procesadores MIPS
# Objetivo: Calcular Y[i] = A * X[i] + B e identificar riesgos de datos.
.data
    vector_x: .word 1, 2, 3, 4, 5, 6, 7, 8
    vector_y: .space 32          # Espacio para 8 enteros (8 * 4 bytes)
    const_a:  .word 3
    const_b:  .word 5
    tamano:   .word 8
.text
.globl main
main:
    # --- Inicialización ---
    la $s0, vector_x      # Dirección base de X
    la $s1, vector_y      # Dirección base de Y
    lw $t0, const_a       # Cargar constante A
    lw $t1, const_b       # Cargar constante B
    lw $t2, tamano        # Cargar el tamaño del vector
    li $t3, 0             # Índice i = 0
loop:
    # --- Condición de salida ---
    beq $t3, $t2, fin     # Si i == tamano, salir del bucle

    # --- Cálculo de dirección de memoria ---
    sll $t4, $t3, 2       # Desplazamiento: t4 = i * 4
    addu $t5, $s0, $t4    # t5 = dirección de X[i]

    # --- Carga de dato ---
    lw $t6, 0($t5)        # Leer X[i]

    # --- OPTIMIZACIÓN: instrucción independiente movida aquí ---
    # Esta instrucción no depende de $t6, así que "rellena" el hueco
    # que antes causaba el stall de Load-Use.
    addu $t9, $s1, $t4    # t9 = dirección de Y[i]

    # --- Operación aritmética ---
    mul $t7, $t6, $t0     # t7 = X[i] * A  (ya no hay stall: $t6 tuvo tiempo de propagarse)
    addu $t8, $t7, $t1    # t8 = t7 + B    (dependencia mul-addu, resuelta por forwarding)

    # --- Almacenamiento de resultado ---
    sw $t8, 0($t9)        # Guardar resultado en Y[i]

    # --- Incremento y salto ---
    addi $t3, $t3, 1      # i = i + 1
    j loop
fin:
    # --- Finalización del programa ---
    li $v0, 10            # Syscall para terminar ejecución
    syscall