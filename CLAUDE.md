# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal blog powered by Jekyll and GitHub Pages, located at https://guo-sj.github.io/. The site follows the UNIX philosophy of "Once do one thing and do it well" - each blog post focuses on solving one small problem, and combining multiple posts solves larger problems like building blocks.

## Directory Structure

```
guo-sj.github.io/
├── docs/               # Main Jekyll site directory
│   ├── _config.yml     # Jekyll configuration
│   ├── _posts/         # Blog posts (YYYY-MM-DD-title.md format)
│   ├── _includes/      # Custom includes (mathjax.html, mermaid.html, etc.)
│   ├── _layouts/       # Custom layouts (default.html extends Minima)
│   ├── _sass/          # SASS stylesheets
│   ├── assets/         # Static assets (images, CSS, etc.)
│   ├── categories.html # Categories listing page
│   └── *.md            # Additional pages (about.md, write-rules.md)
└── README.md
```

## Common Commands

### Install Dependencies
```bash
cd docs
bundle install
```

### Serve Locally (Development)
```bash
cd docs
bundle exec jekyll serve
```
The site will be available at http://localhost:4000

## Architecture & Configuration

### Theme
- Uses **Minima** theme with dark skin (`minima.skin: dark`)
- Configured for GitHub Pages deployment (`gem "github-pages", "~> 219"`)

### Key Plugins
- `jekyll-feed` - RSS feed generation
- `jekyll-sitemap` - Sitemap generation
- `jekyll-seo-tag` - SEO meta tags
- `jemoji` - GitHub emoji support

### Markdown Processor
- Uses GitHub Flavored Markdown (GFM): `markdown: GFM`

### Custom Layout
The custom `default.html` layout (`docs/_layouts/default.html`) extends Minima and adds:
1. MathJax support for LaTeX equations (via `mathjax.html` include)
2. Mermaid diagram support (via `mermaid.html` include)
3. Gitalk comment system for posts
4. Custom head include (`head-custom.html`)

## Post Front Matter Requirements

```yaml
---
layout: post
title: "Post Title"
date: YYYY-MM-DD HH:MM:SS +0800
categories: CategoryName
mathjax: true   # Include if post has LaTeX equations
mermaid: true    # Include if post has Mermaid diagrams
---
```

## Writing Rules

From `docs/write-rules.md`:

1. Keep posts short and focused - each post solves one small problem
2. For technical posts: Use English titles and terminology for accuracy (reduces ambiguity)
3. Categories in front matter should use **Title Case** (e.g., `Linux` not `linux`) for better category page display
4. When mixing Chinese and English, separate with a space (e.g., `grpc 机制` not `grpc机制`)

## Categories Generation

Use `./get_categories.sh` to generate category listings:
```bash
:!./get_categories.sh "in docs/_posts/ dir
:split categories
```

## Site Configuration

- Title: Guoshijie's Blog
- URL: https://guo-sj.github.io
- Base URL: "" (empty - served from root)
- Author: guo-sj
- Header pages: categories.html, about.md, write-rules.md
