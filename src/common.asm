          global     itoa
          global     println_num
          global     open_file_arg

WRITE_SYSCALL  EQU 1
OPEN_SYSCALL   EQU 2

STDIN_FD       EQU 0
STDOUT_FD      EQU 1



          section   .data
print_num_buf: times 64 db 0

          section   .text

; itoa - converts an unsigned integer into its ascii representation
; inputs:
;   rax - the number
;   rbx - the pointer to the buffer
; outputs:
;   rax - 0: success, 1: error
;   rbx - the length
MAX_SIZE EQU 1000000000
START_DIVISOR EQU MAX_SIZE / 10
ASCII_NUM EQU 48
itoa:
; r12: whether we are in the leading zeroes (bool)
; r11: buffer start
; r10: number
; r9: divisor
; r8: current buffer pointer
          mov       r12, 1
          mov       r10, rax

          cmp       r10, MAX_SIZE
          jge       number_too_big

          mov       r9, START_DIVISOR
          mov       r11, rbx
          mov       r8, rbx

          cmp       rax, 0
          jz        write_zero_return
div_loop:
          ; first division for getting the mod of the number
          xor       rdx, rdx
          mov       rax, r10
          mov       rcx, r9
          div       rcx
          ; if rax is non-zero or we are not in the leading zeroes, write into the buffer
          cmp       rax, 0
          jne       write_ascii_into_buffer
          cmp       r12, 0
          jz        write_ascii_into_buffer
          ; else, skip the write
          jmp       take_remainder_of_number

write_ascii_into_buffer:
          ; write the ascii number into the buffer
          add       rax, ASCII_NUM
          mov       byte [r8], al
          inc       r8
          xor       r12, r12            ; we are past the leading zeroes, set it to false

take_remainder_of_number:
          ; if the divisor is one, we are done here
          cmp       r9, 1
          je        return_success

          ; now take the remainder of the number for the next loop
          xor       rdx, rdx
          mov       rax, r10
          mov       rcx, r9
          div       rcx
          mov       r10, rdx            ; nom = num % div

          ; divide the divisor by ten
          xor       rdx, rdx
          mov       rax, r9
          mov       rcx, 10
          div       rcx
          mov       r9, rax

          jmp       div_loop

write_zero_return:
          mov       byte [r8], '0'
          inc       r8
return_success:
          ; calculate the length into r8
          sub       r8, r11
          mov       rax, 0      ; return the success code 0
          mov       rbx, r8     ; return the length
          ret
number_too_big:
          mov       rax, 1      ; return error code 1
          mov       rbx, 0      ; we've written nothing
          ret

ASCII_NEWLINE EQU 10

; println_num
; prints a number to stdout
; inputs:
;   rax - the number
println_num:
          mov       rbx, print_num_buf
          call      itoa

          ; add a trailing newline
          mov       byte [print_num_buf + rbx], ASCII_NEWLINE
          inc       rbx

          mov       rdx, rbx             ; len
          mov       rax, WRITE_SYSCALL
          mov       rdi, STDOUT_FD
          mov       rsi, print_num_buf
          syscall
          ret


; open_file_arg
; opens the file, stdin if it's '-'
; inputs:
;   rax - filename
; outputs:
;   rax - fd, <0 if there was an error
open_file_arg:
          ; first, check whether the filename is -
          cmp       byte [rax], '-'
          jne       normal_filename
          cmp       byte [rax + 1], 0
          jne       normal_filename

          ; filename is just minus
          mov       rax, STDIN_FD
          ret

normal_filename:
          ; we have a normal file that we must open

          mov       rdi, rax
          mov       rax, OPEN_SYSCALL
          xor       rsi, rsi            ; no flags
          xor       rdx, rdx            ; read-only mode
          syscall
          ret
