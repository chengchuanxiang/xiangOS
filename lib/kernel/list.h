#ifndef LIB_KERNEL_LIST_H
#define LIB_KERNEL_LIST_H
#include "global.h"
//获得成员member在结构体中的偏移量
#define offset(struct_type, member) (int)(&((struct_type*)0)->member) //也可用0xfffff000 & (&(PCB.general_tag))
//获得elem_ptr指针（在结构体中对应的名字为struct_member_name）所在的结构体指针（用指针指减去偏移量）
#define elem_to_entry(struct_type, struct_member_name, elem_ptr) \
			(struct_type*)((int)elem_ptr - offset(struct_type, struct_member_name))

typedef struct list_elem{
	struct list_elem *prev;
	struct list_elem *next;
}list_elem;

typedef struct list{
	struct list_elem head;
	struct list_elem tail;
}list;

typedef bool (function)(list_elem*, int arg);

void list_init(list*);
void list_insert_before(list_elem *before, list_elem *elem);
void list_push(list *plist, list_elem *elem);
void list_iterate(list *plist);
void list_append(list *plist, list_elem *elem);
void list_remove(list_elem *elem);
list_elem* list_pop_first(list *plist);
bool list_empty(list *plist);
uint32_t list_len(list *plist);
list_elem* list_traversal(list *plist, function func, int arg);
bool elem_find(list *plist, list_elem *elem);
#endif