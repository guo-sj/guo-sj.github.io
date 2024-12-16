---
layout: post
title: "在 Github Page 上使用 Mermaid 画图"
date:  2024-12-14 10:11:53 +0800
mathjax: false
mermaid: true
categories: Front-end
---

> 如何在 Github Page 上使用 Mermaid 画图？

这个问题困扰了我好久。最近对象在准备机试，周末也不出去玩了，就在家刷题。借这个机会，我把这个问题解决了～

第一步，把如下代码加到 `_includes/mermaid.html`：
```html
{% if page.mermaid %}
    <!-- 使用最新版本的 mermaid.min.js -->
    <script src="https://cdn.jsdelivr.net/npm/mermaid@latest/dist/mermaid.min.js"></script>
    <script>
        // 页面加载的时候自动渲染 mermaid 图片
        mermaid.initialize({startOnLoad:true});
    </script>
{% endif %}
```

第二步，在 `_layouts/default.html` 中增加如下代码，用于在页面渲染时包含 `mermaid.html` 的内容：
```html
{% raw %}
  {% include mermaid.html %}
{% endraw %}
```

第三步，在需要文章的开头增加 `mermaid: true` 或 `mermaid: false` 去打开或关闭加载 `mermaid.js` 库，并用 `<div class="mermaid">` 和 `</div>` 把需要渲染的 `mermaid` 语句括起来。如：
```markdown
<div class="mermaid">
graph LR
    A --- B
    B-->C[Happy]
    B-->D(Sad);
</div>
```
渲染出来的效果是：

<div class="mermaid">
graph LR
    A --- B
    B-->C[Happy]
    B-->D(Sad);
</div>
