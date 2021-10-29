---
layout: post
title: Vim Plugin Install
date: 2021-10-27 15:06:40 +0800
categories: vim
---

To install a vim plugin, you need just a `plugin manager` and the `plugins` you want to install.

## Linux platform

### Plugin manager
There are many vim plugin managers, and here `vim-pathogen` is preferred. To install `vim-pathogen` , first 
make sure you have `.vim/autoload and .vim/bundle` directories, if not, using the following command to create:
```
    $ mkdir -p ~/.vim/autoload ~/.vim/bundle
```

Then use *curl* command to get `vim-pathogen`:
```
    $ curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
```

Another way to get `vim-pathogen` is using *git clone*:
```
    $ git clone https://github.com/tpope/vim-pathogen 

    $ cp ./vim-pathogen/autoload/pathogen.vim ~/.vim/autoload
```

And add these statements to your `.vimrc` file:
```
    execute pathogen#infect()
    syntax on
    filetype plugin indent on
```

### Install plugin
When you've got `vim-pathogen`, install plugin becomes pretty easy. Here, 
we want to install some pretty useful plugins:

#### vim-colors-solarized
[vim-colors-solarized](https://github.com/altercation/vim-colors-solarized) is Solarized
Colorscheme for Vim.

To install it:
```
    $ cd ~/.vim/bundle && git clone https://github.com/altercation/vim-colors-solarized.git
```

#### Nerdtree
The [NERDTree](https://github.com/preservim/nerdtree) is a file system
explorer for the Vim editor. 

To install it: 
```
    $ cd ~/.vim/bundle && git clone https://github.com/preservim/nerdtree.git
```

#### Syntax-Sensible
[Syntax-Sensible](https://github.com/tpope/vim-sensible) is a Vim plugin which
show you syntax error in current editing file.

To install it:
```
    $ cd ~/.vim/bundle && git clone https://github.com/tpope/vim-sensible.git
```

#### vim-barbaric
vim + non-Latin input = pain. [Barbaric](https://github.com/rlue/vim-barbaric) 
is the cure.

To install it:
```
    $ cd ~/.vim/bundle && git clone https://github.com/rlue/vim-barbaric.git
```

#### vim-airline
[vim-airline](https://github.com/vim-airline/vim-airline) is a Vim plugin
  which provides a lean & mean status/tabline for vim that's light as air.

To install it:
```
    $ cd ~/.vim/bundle && git clone https://github.com/vim-airline/vim-airline.git
```

#### vim-fugitive
[vim-fugitive](https://github.com/tpope/vim-fugitive) is the premier Vim plugin for Git. Or maybe it's the premier Git 
plugin for Vim? Either way, it's "so awesome, it should be illegal". That's why it's called Fugitive.

To install it:
```
    $ cd ~/.vim/bundle && git clone https://github.com/tpope/vim-fugitive
```

#### vim-gitgutter
[vim-gitgutter](https://github.com/airblade/vim-gitgutter) is a Vim plugin which shows a git diff in the asdf sign column. 
It shows which lines have been added, modified, or removed. You can also preview, stage, and undo individual hunks; and 
stage partial hunks. The plugin also provides a hunk text object.

To install it:
```
    $ cd ~/.vim/bundle && git clone https://github.com/airblade/vim-gitgutter
```

## Windows platform

In windows platform, install vim plugin become more simple. Open your windows terminal (wsl) and type:
```
mkdir -p ~/vimfiles/pack/vendor/start

cd ~/vimfiles/pack/vendor/start && git clone https://github.com/preservim/nerdtree
```

## Some advice
If your concern, I would like to show some advice about vim and vim plugin:

First, Vim is awesome, almost everyone who knows a bit of Vim will agree with
that.  As far as I have known, Vim (8.0 or higher version) is strong enough to handle
many kinds of text based tasks of a few popular languages, like C, C++, Python, Markdown,
etc. and that's why I recommend that **Don't be so hasty to install plugins, 
only do that whenever you really need**.

Second, the process of learning Vim is fun. All the things you need to do are:
```
    while (1)
        read some manual/articles/books of Vim
        do some related practice
    end while
```

By doing this loop over again and over again, you will end up finding that your editing
is getting as fast as you think.

Finally, my [.vimrc](/assets/vim/vimrc).
