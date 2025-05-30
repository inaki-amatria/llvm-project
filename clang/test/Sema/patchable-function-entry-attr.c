// RUN: %clang_cc1 -triple aarch64 -fsyntax-only -verify %s

// expected-error@+1 {{'patchable_function_entry' attribute takes at least 1 argument}}
__attribute__((patchable_function_entry)) void f(void);

// expected-error@+1 {{expected string literal as argument of 'patchable_function_entry' attribute}}
__attribute__((patchable_function_entry(0, 0, 0))) void f(void);

// expected-error@+1 {{section argument to 'patchable_function_entry' attribute is not valid for this target}}
__attribute__((patchable_function_entry(0, 0, ""))) void f(void);

// expected-error@+1 {{'patchable_function_entry' attribute takes no more than 3 arguments}}
__attribute__((patchable_function_entry(0, 0, "__section", 0))) void f(void);

// expected-error@+1 {{'patchable_function_entry' attribute requires a non-negative integral compile time constant expression}}
__attribute__((patchable_function_entry(-1))) void f(void);

int i;
// expected-error@+1 {{'patchable_function_entry' attribute requires parameter 0 to be an integer constant}}
__attribute__((patchable_function_entry(i))) void f(void);

// expected-error@+1 {{'patchable_function_entry' attribute requires integer constant between 0 and 2 inclusive}}
__attribute__((patchable_function_entry(2, 3))) void f(void);
