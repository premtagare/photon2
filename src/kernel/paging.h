// paging.h

struct page_entry
{
    unsigned present        : 1;
    unsigned read_or_write  : 1;
    unsigned access_prev    : 1;  // Kernel or User
//    unsigned zeros1         : 2;
    unsigned accessed       : 1;
    unsigned dirty          : 1;
    unsigned unused         : 7;
//    unsigned zeros2         : 2;
//    unsigned avl_sysprog    : 3;
    unsigned frame_addr     :20;
};

struct page_table_entry
{
    struct page_entry pages[1024];
};

struct page_directory
{
    struct page_table_entry *page_tables[1024];
    unsigned phy_addr[1024];
	unsigned DirPhyAddr;
};
