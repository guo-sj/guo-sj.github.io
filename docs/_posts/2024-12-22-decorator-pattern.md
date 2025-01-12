---
layout: post
title: "Decorator Pattern"
date:  2024-12-22 10:11:53 +0800
mathjax: false
mermaid: true
categories: Design-Pattern
---

> 装饰模式（Decorator Pattern）：动态地给一个对象增加一些额外的职责，就增加对象的功能来说，
装饰模式比生成子类实现更加灵活。

<div class="mermaid">
classDiagram
    class Componont {
        +display() void
    }
    class ComponontDecorator {
        -componont : Componont
        +ComponontDecorator(Componont componont)
        +display() void
    }
    Componont <|-- Window
    Componont <|-- TextBox
    Componont <|-- ListBox
    Componont <|-- ComponontDecorator
    Componont <--o ComponontDecorator
    ComponontDecorator <|-- ScrollBarDecorator
    ComponontDecorator <|-- BlackBorderDecorator
    class ScrollBarDecorator {
        +ScrollBarDecorator(Componont componont)
        +display() void
        +setScrollBar() void
    }
    class BlackBorderDecorator {
        +BlackBorderDecorator(Componont componont)
        +display() void
        +setBlackBorder() void
    }
    class Window {
        +display() void
    }
    class TextBox {
        +display() void
    }
    class ListBox {
        +display() void
    }
</div>
