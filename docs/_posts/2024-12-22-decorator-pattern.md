---
layout: post
title: "Decorator Pattern"
date:  2024-12-22 10:11:53 +0800
mathjax: false
mermaid: true
categories: Design Pattern
---

先加 UML 图，文字介绍之后再补充～

<div class="mermaid">
classDiagram

class Componont {
    <<Abstract>>
    + display() void
}

class ComponontDecorator {
    - componont : Componont
    + ComponontDecorator(Componont componont)
    + display() void
}

Componont <|-- Window
Componont <|-- TextBox
Componont <|-- ListBox
Componont <|-- ComponontDecorator
Componont <--o ComponontDecorator
ComponontDecorator <|-- ScrollBarDecorator
ComponontDecorator <|-- BlackBorderDecorator

class ScrollBarDecorator {
    + ScrollBarDecorator(Componont componont)
    + display() void
    + setScrollBar() void
}

class BlackBorderDecorator {
    + BlackBorderDecorator(Componont componont)
    + display() void
    + setBlackBorder() void
}

class Window {
    + display() void
}

class TextBox {
    + display() void
}

class ListBox {
    + display() void
}
</div>
