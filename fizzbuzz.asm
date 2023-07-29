;=======================================================
;=====  CONSTANTS
;=======================================================
    section .data
;=======================================================

    newline:        db 10                       ; One byte for newline character
    
    fizz:           db "Fizz",0                 ; One byte "Fizz" string 
    fizzlen equ $ - fizz                        ; Size of "Fizz" string

    buzz:           db "Buzz",0                 ; One byte "Buzz" string
    buzzlen equ $ - buzz                        ; Size of "Buzz" string

    number:         dw 999                      ; Double wor number. 

;=======================================================
;=====  VARIABLES
;=======================================================
    section .bss
;=======================================================

    output_buffer  resb    3                   ; Buffer for three ascii digits


;=======================================================
;=====  BLASTOFF
;=======================================================
    section .text
;=======================================================

    _start:
            xor     r8, r8                      ; Set counter to 0
            inc     r8                          ; Add one to counter, start count at 1. 

    _loop:
            xor     r9, r9                      ; Set r9 to 0
            xor     rdx, rdx                    ; Clear rdx to hold the remainder of division. 
            mov     rax, r8                     ; Put the current number into rax as the quotiant
            mov     rcx, 3                      ; Put 3 into rcx as the devisor
            div     rcx                         ; Divide RAX by rcx (Number/3) and put the remainder into rdx
            cmp     rdx, 0                      ; Check if the remainder is equal to 0 (aka: evenly divisable)
            jnz     _skip_fizz_set              ; Skip setting Fizz if the remainder is not 0
            inc     r9                          ; Increment r9 to set Fizz (r9 = 1)
    _skip_fizz_set:
            xor     rdx, rdx                    ; Clear rdx to hold the remainder of division. 
            mov     rax, r8                     ; Put the current number into RAX as the quotiant. 
            mov     rcx, 5                      ; Put 5 into rcx as the divisor. 
            div     rcx                         ; Divide rax by rcx (Number/5) and put the remainder into rdx
            cmp     rdx, 0                      ; Check if the remainder is equal to 0 (aka: evenly divisable)
            jnz     _skip_buzz_set              ; Skip setting Buzz if the remainder is not 0
            add     r9, 2                       ; Add 2 to r9 to set Buzz
    _skip_buzz_set:
            cmp     r9, 1                       ; Check if Fizz is set 
            jnz     _skip_fizz_print            ; If Fizz not set, skip printing Fizz
            call    _print_fizz                 ; If Fizz is set, print Fizz
            call    _print_newline              ; If Fizz is set, print a newline
            jmp     _continue                   ; Restart loop
    _skip_fizz_print:
            cmp     r9, 2                       ; Check if Buzz is set
            jnz     _skip_buzz_print            ; If Buzz  not set, skip printing Buzz
            call    _print_buzz                 ; If Buzz is set, print Buzz
            call    _print_newline              ; If Buzz is set, print a newline
            jmp     _continue                   ; Restart loop
    _skip_buzz_print:
            cmp     r9, 3                       ; Check if both FizzBuzz is set
            jnz     _skip_fizzbuzz_print        ; If FizzBuzz not set, skip printing FizzBuzz
            call    _print_fizz                 ; If FizzBuzz is set, print Fizz
            call    _print_buzz                 ; If FizzBuzz is set, print Buzz
            call    _print_newline              ; If Fizzbuzz is set, print a newline
            jmp     _continue                   ; Restart loop
    _skip_fizzbuzz_print:                       
            push    qword[number]               ; Push the value of number onto the stack to preserve it 
            call    _print_num                  ; If Fizz, Buzz, or FizzBuzz not set, then print the current number
            pop     qword[number]               ; Pop the number value off the stack and back into 'number'
    _continue:
            cmp     r8, [number]                ; Check if r8 (the current number) equals 'number' (the total numbers to check) 
            je      _exit                       ; If r8 equals 'number, call _exit
            inc     r8                          ; Increment r8 (the current number), by 1
            jmp     _loop                       ; Restart the main loop

;=======================================================
;=====  EXIT
;=======================================================
    _exit:
            mov     rax, 60                     ; Move 60 into rax, setting the exit system call
            xor     rdi, rdi                    ; Set rdi to 0, setting exit code 0
            syscall                             ; Call exit

;=======================================================
;=====  SUBROUTINES
;=======================================================

    _print_fizz:
            mov     rax, 1                      ; Move 1 into rax, setting the write system call 
            mov     rdi, 1                      ; Move 1 into rdi, setting std out 
            mov     rsi, fizz                   ; Move 'fizz' into rsi; the pointer to the string to be printed
            mov     rdx, fizzlen                ; Move the length of the string into rdx
            syscall                             ; Call write
            ret                                 ; Return from subroutine

    _print_buzz:
            mov     rax, 1                      ; Move 1 into rax, setting the write system call
            mov     rdi, 1                      ; Move 1 into rdi, setting std out
            mov     rsi, buzz                   ; Move 'buzz' into rsi; the pointer to the string to be printed
            mov     rdx, buzzlen                ; Move the length of the string into rdx
            syscall                             ; Call write
            ret                                 ; Return from subroutine
                                                
                                                ; Convert number to ascii for printing
    _print_num:
            mov     rax, r8                     ; Move the current number into rax
            mov     r9, 2                       ; Set r9 to 2 for indexing into output_buffer
                                                
        _each_digit_loop:
                mov     rdx, 0                      ; Clear rdx to hold the remainder of division
                mov     rcx, 10                     ; Set rcx to 10, the quotiant for division
                div     rcx                         ; Divide rax by rcx (current digit/10) and put the remainder in rdx

                add     rdx, 0x30                   ; Add 0x30 to the digit, converting it to it's ascii value
                mov     [output_buffer+r9], dl      ; Store digit in the output_buffer, from left to right
                dec     r9                          ; Move offset back one

                cmp     rax, 0                      ; Check if there are more digits
                jnz     _each_digit_loop            ; If there are no more digits, loop again

                                                ; Print the result of the conversion
            mov     rax, 1                      ; Move 1 into rax, setting the write system call
            mov     rdi, 1                      ; Move 1 into rdi, setting std out
            mov     rsi, output_buffer          ; Move 'output_buffer' into rsi, the pointer to the string to be printed
            mov     rdx, 3                      ; Move the length of the string into rdx
            syscall                             ; Call write

            call    _print_newline              ; Print a newline

            ret                                 ; Return from subroutine

    _print_newline:
            mov     rax, 1                      ; Move 1 into rax, setting the write system call
            mov     rdi, 1                      ; Move 1 into rdi, setting std out
            mov     rsi, newline                ; Move 'newline' into rsi, the pointer to the char to be printed
            mov     rdx, 1                      ; Move 1 into rdx, the size of one char
            syscall                             ; Call write
            ret                                 ; Return from subroutine
