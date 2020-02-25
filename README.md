# hello-asm
A barebones example that goes beyond the usual Hello-World for the original Gameboy.

It is a very basic but complete game. 

![catgame_title](https://github.com/madpew/hello-asm/catgame_title.gif)![catgame_game](https://github.com/madpew/hello-asm/catgame_game.gif)



## The story so far

Most of the available assembly examples for the original gameboy are either minimalistic "hello world" examples or huge complicated games.
While programming for the gameboy can be very simple (as shown in most hello-worlds by taking many shortcuts), doing things the right way requires to dive into a few advanced concepts.
Not knowing those can make full-blown examples very hard to read.

The aim of this repository is to create an easy to understand example without taking shortcuts and implementing best-practice solutions for common problems.
Ideally, once completed, this could be turned into a tutorial/article-series that bridges the gap from the usual hello-world to the full examples by explaining different concepts step by step.

This is a living repository and might get a bit messy while I'm working on new things.



## Caution

- This project is a work in progress and should not be considered bug-free.
- Faulty software can harm your real gameboy hardware.
- I'm not an expert, use with care at your own risk (if you plan on run it on the real hardware anyways).



## Usage

This project is built on windows using [rgbds](https://github.com/rednex/rgbds) and developed in VSCode.

The tiles and maps used are created using [pewSpriteStudio](https://github.com/madpew/pewSpriteStudio).

For debugging and emulating the gameboy to run the game [BGB](http://bgb.bircd.org/) is recommended.
