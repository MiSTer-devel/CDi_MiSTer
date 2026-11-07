OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    ram  (wxai!r) : ORIGIN = 0x00000000, LENGTH = 11000
}

SECTIONS
{
    __stack_size = 420;

    /* Code and read-only data */
    .text : {
        *(.init)         /* startup code */
        *(.text*)        /* main program code */
        *(.rodata*)      /* read-only data (const) */
    } > ram

    /* Zero-initialized data */
    .bss : {
        __bss_start = .;
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        __bss_end = .;
    } > ram

    .noinit (NOLOAD) :
    {
        . = ALIGN(4);
        *(.noinit .noinit.*)
    } > ram

    .stack  : ALIGN(16)
    {
        . = __stack_size;
        _stack_top = .;
    } > ram
}
