// paging.c
// Routines to allocate memory through paging

#include "paging.h"
#include "common.h"
#include "memory.h"
#include "monitor.h"
#include "isr.h"

#define INDEX(frame)    (frame/32)
#define POSITION(frame) (frame%32)

extern unsigned mem_limit;
extern unsigned alloc_ptr;

struct page_directory *kernel_page_dir;
 
struct page_directory *current_page_dir;

unsigned total_frames = 0;
unsigned *frame_status;

static void page_fault(registers_t regs);
struct page_entry * get_page_entry(unsigned logical_addr, struct page_directory *directory);
void switch_page_directory(struct page_directory *directory);


int initialise_paging()
{
    unsigned i = 0x0;
    struct page_entry *page_addr;

    total_frames = mem_limit/0x1000;
    frame_status = (unsigned*)kmalloc(INDEX(total_frames),0);
    memset_int(frame_status,0,INDEX(total_frames));

    kernel_page_dir = (struct page_directory *) kmalloc(sizeof(struct page_directory),1);
    current_page_dir = kernel_page_dir;

    page_addr = get_page_entry(i,kernel_page_dir);
    alloc_frame(page_addr,1,0);

    for(i=0x1000; i< alloc_ptr ; i+= 0x1000)
    {
        page_addr = get_page_entry(i,kernel_page_dir);
        if( page_addr == NULL)
        {
            monitor_write("Error retrieving page entry\n");
            return -1;
        }
        alloc_frame(page_addr,1,0);
    }

    register_interrupt_handler(14,page_fault);

    switch_page_directory(kernel_page_dir);

    return 0;
}

unsigned get_new_frame()
{
    int i,j;
    for(i=0; i< total_frames/32; i++)
    {
        if( frame_status[i] == 0xFFFFFFFF )   // None of these are free
            continue;
        for(j=0; j< 32; j++)
        {
            unsigned assigned = frame_status[i] & 0x1<<j;
            if(!assigned)
                return i*32+j;
        }
    }
    return 0xFFFFFFF;
}

void set_frame(unsigned frame_num)
{
    frame_status[INDEX(frame_num)] |= (0x1 << POSITION(frame_num));
}

void clear_frame(unsigned frame_num)
{
    frame_status[INDEX(frame_num)] &= ~(0x1 << POSITION(frame_num));
}

int alloc_frame(struct page_entry *page,int prev,int rw)
{
    unsigned new_frame;
    if(page->frame_addr)
        return 0;
    new_frame = get_new_frame();
    if( new_frame == 0xFFFFFFFF )
    {
        monitor_write("Free frame not found\n");
        return -1;
    }
    set_frame(new_frame);
    page->present = 1;
    page->read_or_write = (rw)?1:0;
    page->access_prev = (prev)?1:0;
    page->frame_addr = new_frame;
}

void free_frame(struct page_entry *page)
{
    if(page->frame_addr == 0)
        return;
    clear_frame(page->frame_addr);
    page->frame_addr = 0x0;
}

struct page_entry * get_page_entry(unsigned logical_addr, struct page_directory *directory)
{
    unsigned dir_off        = logical_addr >> 22;  // highest 10 bits
    unsigned page_table_off = (logical_addr >> 12) % 1024; // next 10 bits

    if(directory->page_tables[dir_off])
    {
        return &(directory->page_tables[dir_off]->pages[page_table_off]);
    }
    else
    {
        unsigned paget_addr = (unsigned) kmalloc(sizeof(struct page_table_entry),1);
        memset_int(paget_addr,0,sizeof(struct page_table_entry));
        directory->page_tables[dir_off] = (struct page_table_entry*) paget_addr;
        
        paget_addr |= 0x7; // Flags - present, r/w, u/s
        directory->phy_addr[dir_off] = paget_addr;
        
        return &(directory->page_tables[dir_off]->pages[page_table_off]);
    }
}         

void switch_page_directory(struct page_directory *directory)
{
    unsigned cr0;
    current_page_dir = directory;
    asm volatile("mov %0, %%cr3":: "r"(&directory->phy_addr));
    asm volatile("mov %%cr0, %0": "=r"(cr0));
    cr0 |= 0x80000000; // Enable paging!
    asm volatile("mov %0, %%cr0":: "r"(cr0));

}
     
static void page_fault(registers_t regs)
{
    unsigned fault_addr;
    asm volatile("mov %%cr2, %0" : "=r" (fault_addr));

    monitor_write("Page fault at : ");
    print_hex(fault_addr);
    monitor_write("\n");
    if( !(regs.err_code & 0x1) )
    {
        monitor_write("Page not found\n");
        //return;
    }

    if( regs.err_code & 0x2 )
        monitor_write("read only\n");

    if( regs.err_code & 0x4 )
        monitor_write("user mode\n");

    if( regs.err_code & 0x8 )
        monitor_write("trying to change reserved bits\n");

    if( regs.err_code & 0x10 )
        monitor_write("Error during intstruction fetch\n");

    PANIC("Page fault");
}
