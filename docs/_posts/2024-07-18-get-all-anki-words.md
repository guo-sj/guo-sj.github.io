---
layout: post
title: "使用lex和makefile得到所有的anki单词（自己的第一个词法分析器）"
date:  2024-07-18 10:11:53 +0800
mathjax: true
categories: Lex && Yacc
---

哇，好久没有写技术博客了。感觉自己已经离 hacker 的梦想越来越远了呢～

最近在学习 lex 和 yacc，主要是想彻底搞清楚《The UNIX Programming Environment》中的 `hoc` 语言到底是怎么实现的，自己能否在上面
加上一些自己感兴趣的功能，甚至，之后创建一门自己的编程语言。

这篇文章记录一下自己用 lex 制作的一个词法分析器，用于提取文本中 html 标签 `<b></b>` 之间的英文单词，并使用 makefile 实现自动化。

2022/09/01 之前我还保持着每天用 anki 背单词的习惯（现在为什么不背了？因为进华为了时间不允许:(）。我的 anki 卡片通常长这个样子：
```
An application that is offering services (the server) waits for messages to come in on a specific port <b>dedicated </b>to that service.	designed to be used for one particular purpose (专用)	LongTermLearning
```
`<b></b>` 之间的就是需要记忆的单词。我现在要做的事情是把这些单词使用 lex 提取出来：
```lex
%{
// 提取 html 标签 <b></b> 中的内容
%}
%%

"<b>"[a-zA-Z ]+"</b>" {
                  char *start = yytext + 3; // 跳过 <b>
                  char *end = strstr(start, "</b>");
                  if (!end) return 1;
                  *end = '\0';
                  printf("%s\n", start);
};
.|\n ;
%%
int main(void)
{
    yylex();
    return 0;
}
```

这里值得注意的是，需要将 `<b>` 和 `</b>` 用 `""` 括起来，用于表示它们是**字符串**；因为 `<` 和 `>` 在 lex 中，通常用于定义开始状态和结束状态，
属于特殊字符。

`yytext(char *)` 指向匹配到的字符串，拿上面的 anki 卡片举例，`yytext` 就指向 `<b>dedicated </b>`。这里匹配后执行的动作就是把 `<b></b>`
从字符串中去掉。

接着，我们用 makefile 去自动化生成单词列表：
```makefile
TARGET = first
SOURCE = 01.l
RESULT = all_anki_words
BACKUP_FILE = newest_note

all: $(RESULT)

$(RESULT): $(TARGET) $(BACKUP_FILE)
	cat ./$(BACKUP_FILE) |\
	./$(TARGET) |\
	tr A-Z a-z |\
	sed -E 's/^[\t ]+//g' |\
	sed -E 's/[\t ]+$$//g' |\
	sort |\
	uniq >$(RESULT)
	
$(TARGET): $(SOURCE)
	lex $(SOURCE)
	cc lex.yy.c -o $(TARGET) -ll

$(BACKUP_FILE):
	file_a=$$(ls -t ../ankiBackup/ | head -1) &&\
	cp ../ankiBackup/$$file_a $(BACKUP_FILE)

clean:
	rm -rf lex.yy.c $(TARGET) $(RESULT) $(BACKUP_FILE)
	rb
```

anki 仓库的整个目录结构如下：
```
.
├── ankiBackup
│   ├── 2021_10_30_All_Decks_Notes.txt
│   ├── 2021_10_5_All_Decks_Notes.txt
│   ├── 2021_11_28_All_Decks_Notes.txt
│   ├── 2021_6_27_All_Decks_Notes.txt
│   ├── 2021_7_29_All_Decks_Notes.txt
│   ├── 2021_9_6_All_Decks_Notes.txt
│   ├── 2022_12_25_All_Decks_Notes.txt
│   ├── 2022_1_2_All_Decks_Notes.txt
│   ├── 2022_2_1_All_Decks_Notes.txt
│   ├── 2022_3_5_All_Decks_Notes.txt
│   ├── 2022_4_10_All_Decks_Notes.txt
│   ├── 2022_5_3_All_Decks_Notes.txt
│   ├── 2022_6_3_All_Decks_Notes.txt
│   ├── 2022_7_2_All_Decks_Notes.txt
│   ├── 2022_8_8_All_Decks_Notes.txt
│   ├── 2022_9_11_All_Decks_Notes.txt
│   ├── 2023_01_22_All_Decks_Notes.txt
│   ├── 2023_5_21_All_Decks_Notes.txt
│   ├── 2023_7_16_All_Decks_Notes.txt
│   └── 2024_7_18_All_Decks_Notes.txt
├── ankiWords
│   ├── english
│   │   ├── 2021
│   │   ├── 2022
│   │   └── 2023
│   ├── hackers
│   ├── japan
│   └── toeic
│── getAllAnkiWords
│   ├── 01.l
│   └── makefile
└── README.md
```

思路也比较简单：
1. 把最近一次的 anki 卡片集合拷贝过来，对应变量 `BACKUP_FILE`
2. 使用 lex 生成的 lexer 进行匹配
3. 用 `tr` 将所有的大写字母转换成小写字母
4. 使用 `sed` 将字符串前后的 whitespace 去掉
5. 用 `sort` 和 `uniq` 去重

这个 makefile 需要注意 3 点：
- `$` 在 makefile 中有特殊的含义，用于表示变量引用。如果需要在 makefile 中使用`$`的 literal meaning，需要使用 `$$` 去代替。如上述 makefile 中的`sed -E 's/[\t ]+$$//g'` 和 `file_a=$$(ls -t ../ankiBackup/ | head -1)`
- `+` 属于 extended regular expression，如果需要在 gnu sed 中使用的话，需要加上 `-E` 标志位
- 在 makefile 中，执行 shell 脚本是每行是由一个 shell 单独执行的，所以使用 shell 变量时需要将变量定义和使用的脚本用 `$$\` 合成一行，如：
```makefile
$(BACKUP_FILE):
	file_a=$$(ls -t ../ankiBackup/ | head -1) &&\
	cp ../ankiBackup/$$file_a $(BACKUP_FILE)
```

最后代码是放在 [anki](https://github.com/guo-sj/anki) 的 `getAllAnkiWords` 目录下，感兴趣的朋友也可以下载下来体验下。

以上。
