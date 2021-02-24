# Lua Timer

Timing a function call in Lua is actually trivial...

```lua
local ti = os.clock()
your_function()
local tf = os.clock()
local dt = tf - ti
```

But the script also provides statistics about the time random variable: *mean*, *standard deviation*, *maximum* and *minimum* values.
Plus, since some batches might take some time, there is a built-in *progress bar* option to keep track of progress.

## Dependencies

* Lua >= 5.1

## Setup

After cloning this repository anywhere, it is nice to create an alias.

```sh
git clone https://github.com/guidanoli/lua-timer.git ~/.lua-timer
echo "alias lua-timer='lua ~/.lua-timer/timer.lua'" >> ~/.bashrc
```

## Usage

Run `lua-timer -h` for usage information.
