---
layout: post
title: "Learn Yacc"
date:  2025-07-06 10:11:53 +0800
mathjax: false
mermaid: false
categories: Lex-And-Yacc
---

## Yacc 知识
yacc 的程序组织格式为：
```
%{
C statements like #include, declaration, etc. (optional)
%}

yacc declaration: lexical tokens, grammar variables,
    precedence and associativity information

%%
grammar rules and actions
%%

more C statements (optional)

main() { ...; yyparse(); ... }
yylex() { ... }
```

yacc 中每个 symbol 都有一个 value，因此每个 symbol 都需要一个 type，这个 type 在程序中用
`YYSTYPE` 表示，其中 YY 是 yacc 的前缀，S 代表的是 Semantic（语义），所以这个词的意思是** Yacc 的语义值类型**。
默认 `YYSTYPE` 的值为 int。如果我们程序中所有的 symbol 的都是一个类型，那么我们可以通过 `#define` 
的方式重载它的值：

```c
#define YYSTYPE double
```

如果我们会用到多个类型，那么常见的做法是通过 `%union` 去定义 parser 中用到的所有 type 类型，
此时 YYSTYPE 就变成了一个联合体类型。如下面这段代码：

```yacc
%union {
    double dval;
    char *sval;
}

%token <dval> REAL
%token <sval> STRING
%type <dval> expr

%left '+' '-'
%left '*' '/'
%right POW

%%

calc: expr { printf("%g\n", $1); }

expr:   expr '+' expr { $$ = $1 + $3; }
        | REAL { $$ = $1; }
        | STRING '=' STRING { $$ = strcmp($1, $3) ? 0.0 : 1.0; }
```

在上面的代码中：
- 我们在 `%union` 中定义了 2 个类型 `double` 和 `char *`，然后在下面给程序中用到的 symbol `REAL`,
`STRING` 和 `expr` 都用这两种类型进行了定义
- `%token` 用来定义 `terminal symbol`，也就是我们在 lex 和 yacc 中说的 token，也是语法树中的叶子节点。
它的语法是 `%token <type> SYMBOL`，如果 `<type>` 省略，那么 `SYMBOL` 的类型默认为 `YYSTYPE`。
- `%type` 用来定义 `non-terminal symbol`，对应的是语法树中的非叶子节点。它的语法为 `%type <type> SYMBOL`，同样的，
如果 `<type>` 省略，那么 `SYMBOL` 的类型默认为 `YYSTYPE`。
- `%left/%right` 用来定义操作符，上面代码的含义是说 `+-` 和 `*/` 都是左结合，而 `POW` 是右结合。水平方向有着同一优先级，
如 `+-` 的计算优先级一样；垂直方向自上往下优先级逐步升高，所以它们的优先顺序为 `+` = `-` < `*` = `/` < `POW`
- `%prec SYMBOL` 说明当前的规则和 SYMBOL 有相同的优先级

## 编译原理知识
我们使用 `context-free grammar（上下文无关文法）` 去描述一门编程语言的语法(syntax)，`context-free grammar` 由 4 个
部分组成：
- 一组 terminal symbols，也叫做 tokens
- 一组 nonterminals，通常叫做 `syntactic variables`（语义变量），每个 nonterminal 都可以由多个 terminal 组合而成
- 一组 productions，一个 production 可以理解为一个语法规则。一个 production 由一个 nonterminal（通常被称做这个 production
 的 *head* 或者 *left side*），一个箭头（->），以及一个由 terminals/nonterminals 组成的序列，通常被称做这个 production 的
*body* 或者 *right side*。production 的目的是指明一个 construct 的形式。如果 production 的 head 表示一个 construct，
那么它的 body 则代表这个 construct 的可以被书写的形式。如：
```
stmt -> if ( expr ) stmt else stmt
```
或者：
```
expr -> NUMBER
expr -> expr + expr
```
通常，多个拥有相同 `head` 的 productions 可以使用 `|`(可以理解为 or) 去合并，所以上面的 productions 可以被合并为：
```
expr -> NUMBER | expr + expr
```

一个空的 terminal 会被写成 `ϵ`。

Parse（解析）就是从 `context-free grammar` 的 start symbol 得到一条编程语言的语句的过程。Parse Tree（解析树）展现
了这个过程。

## bison 的使用
在 MacOS 或者 GNU/Linux 中，已经不建议使用 yacc 去处理 `.y` 文件了，而是建议使用 `bison`，用法如下：
```sh
bison hoc.y # 生成 hoc.tab.c
cc -o hoc hoc.tab.c
```

如果你还有其他文件需要用到中间生成的 `hoc.tab.h` 文件，那么可以加上 `-d` flag。
```sh
bison -d hoc.y # 生成 hoc.tab.h hoc.tab.c
cc -o hoc hoc.tab.c other.c # other.c 中 include 了 hoc.tab.h 文件
```
