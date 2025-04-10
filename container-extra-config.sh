#!/bin/bash

# Disable address space layout randomization
echo 0 > /proc/sys/kernel/randomize_va_space

# Disable THP defragmentation
echo never > /sys/kernel/mm/transparent_hugepage/defrag
