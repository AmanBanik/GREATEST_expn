# Inspect Compiler Assembly and Disassembly

Goal: help the user inspect relevant instructions without requiring them to read the whole file.

1. Confirm project root, source path, compiler, flags, and that `results/` exists. Do not overwrite a previous assembly artifact; use a timestamped output name or ask before replacing it.
2. Generate Intel-syntax assembly using the exact build flags used for the executable, where possible. Note that `-S` compiles source to assembly and does not produce the executable.
3. Start with manageable views: `head`, `grep -n`, and `sed -n`. Explain how to leave `less` (`q`) if it is used.
4. Inspect source function names first, then map them to assembly symbols. C++ names may be mangled or optimized/inlined; use `c++filt`/`objdump -C` where available.
5. For disassembly, use `objdump -d -C ./memory_lab`; avoid dumping an unbounded listing into the chat. Search for a symbol, then print a bounded range.
6. Explain instructions in context. Do not infer that every load reaches DRAM; a load can be served by cache. Treat `prefetch`, vectorization, loop unrolling, and dependency chains as evidence only when they appear in the actual output.
7. Save the command, output filename, compiler flags, and a short interpretation to the session log. Do not modify code just to make assembly easier to read without first explaining why.
