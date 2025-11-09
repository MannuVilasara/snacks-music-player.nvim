# 🎵 snacks-music-player.nvim

A minimal, beautiful music player UI for Neovim using [folke/snacks.nvim](https://github.com/folke/snacks.nvim) and [playerctl](https://github.com/altdesktop/playerctl).

## 📹 Preview

<img width="614" height="287" alt="image" src="https://github.com/user-attachments/assets/f9ded456-6131-4262-8d43-4a0fcdd26af7" />

## ✨ Features

- 🎨 Clean horizontal UI with centered content
- 🌈 Customizable colors with highlight groups
- ✂️ Automatic truncation of long song names
- ⏱️ Real-time progress bar that updates every second
- 🎮 Keyboard controls for play/pause, next, previous
- 🎵 Shows current track, artist, and playback status
- 🪟 Floating window with backdrop
- ⚡ Lightweight and fast

## 📦 Requirements

- Neovim >= 0.9.0
- [folke/snacks.nvim](https://github.com/folke/snacks.nvim)
- [playerctl](https://github.com/altdesktop/playerctl) (for media control via MPRIS)

### Installing playerctl

**Arch Linux:**

```bash
sudo pacman -S playerctl
```

**Ubuntu/Debian:**

```bash
sudo apt install playerctl
```

**macOS:**

```bash
brew install playerctl
```

## 📥 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "MannuVilasara/snacks-music-player.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {},
  keys = {
    { "<leader>mp", desc = "Toggle Music Player UI" },
    { "<leader>m<space>", desc = "Play/Pause Music" },
    { "<leader>mn", desc = "Next Track" },
    { "<leader>mb", desc = "Previous Track" },
  },
}
```

### Custom Configuration

```lua
{
  "MannuVilasara/snacks-music-player.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    -- Window configuration
    width = 62,        -- Window width
    height = 14,       -- Window height
    backdrop = 60,     -- Backdrop opacity (0-100)

    -- Update interval (ms)
    update_interval = 1000,

    -- Progress bar width
    progress_bar_width = 38,

    -- Color configuration (uses Neovim highlight groups)
    colors = {
      border = "FloatBorder",           -- Border color
      title = "Title",                  -- Song title color
      artist = "Comment",               -- Artist name color
      progress_bar = "String",          -- Progress bar color
      time = "Number",                  -- Time display color
      controls = "Special",             -- Controls text color
      status_playing = "String",        -- Playing icon color
      status_paused = "WarningMsg",     -- Paused icon color
    },
  },
  keys = {
    { "<leader>mp", function() require("snacks-music-player").toggle() end, desc = "Toggle Music Player" },
    { "<leader>m<space>", function() require("snacks-music-player").play_pause() end, desc = "Play/Pause" },
    { "<leader>mn", function() require("snacks-music-player").next() end, desc = "Next Track" },
    { "<leader>mb", function() require("snacks-music-player").previous() end, desc = "Previous Track" },
  },
}
```

## 🎮 Usage

### Keybindings

**Default keybindings:**

| Key                | Action                              |
| ------------------ | ----------------------------------- |
| `<leader>mp`       | Toggle music player UI              |
| `<leader>m<space>` | Play/Pause (without opening UI)     |
| `<leader>mn`       | Next track (without opening UI)     |
| `<leader>mb`       | Previous track (without opening UI) |

**Inside the music player UI:**

| Key | Action         |
| --- | -------------- |
| `p` | Play/Pause     |
| `n` | Next track     |
| `b` | Previous track |
| `q` | Close player   |

### API

```lua
local player = require("snacks-music-player")

-- Toggle the UI
player.toggle()

-- Close the UI
player.close()

-- Control playback (works without opening UI)
player.play_pause()
player.next()
player.previous()

-- Get current track info
local info = player.get_track_info()
-- Returns: { title, artist, album, status, position_sec, length_sec }
```

## 🎨 Customization

### Color Customization

You can customize colors by providing different highlight groups in the configuration:

```lua
require("snacks-music-player").setup({
  colors = {
    border = "FloatBorder",
    title = "String",              -- Make title green
    artist = "Comment",            -- Make artist gray
    progress_bar = "Function",     -- Make progress bar cyan
    time = "Number",               -- Make time orange
    controls = "Keyword",          -- Make controls purple
    status_playing = "DiagnosticOk",    -- Green when playing
    status_paused = "DiagnosticWarn",   -- Yellow when paused
  }
})
```

### Custom Colors with RGB

You can also define your own custom highlight groups:

```lua
-- Define custom highlights
vim.api.nvim_set_hl(0, "MyMusicTitle", { fg = "#ff79c6", bold = true })
vim.api.nvim_set_hl(0, "MyMusicProgress", { fg = "#50fa7b" })
vim.api.nvim_set_hl(0, "MyMusicBorder", { fg = "#89b4fa" })

-- Use them in the config
require("snacks-music-player").setup({
  colors = {
    border = "MyMusicBorder",
    title = "MyMusicTitle",
    progress_bar = "MyMusicProgress",
  }
})
```

### Available Color Options

| Option           | Description         | Default       |
| ---------------- | ------------------- | ------------- |
| `border`         | Border color        | `FloatBorder` |
| `title`          | Song title color    | `Title`       |
| `artist`         | Artist name color   | `Comment`     |
| `progress_bar`   | Progress bar color  | `String`      |
| `time`           | Time display color  | `Number`      |
| `controls`       | Controls text color | `Special`     |
| `status_playing` | Playing icon color  | `String`      |
| `status_paused`  | Paused icon color   | `WarningMsg`  |

## 🔧 Supported Music Players

Any media player that supports MPRIS (via playerctl):

- Spotify
- VLC
- Chrome/Chromium/Brave (web players)
- Firefox (web players)
- Rhythmbox
- Clementine
- And many more...

## 📝 Notes

- Requires `playerctl` to be installed and in your PATH
- Works with any MPRIS-compatible media player
- The UI updates automatically every second while open
- Progress bar shows current position in the track

## 🐛 Troubleshooting

**Music player doesn't show anything:**

- Make sure playerctl is installed: `playerctl --version`
- Check if playerctl can see your player: `playerctl -l`
- Verify music is playing: `playerctl status`

**UI looks misaligned:**

- Try a different terminal or font
- Adjust the `width` option in configuration
- Make sure you're using a monospace font

## 📄 License

MIT

## 🙏 Credits

- [folke/snacks.nvim](https://github.com/folke/snacks.nvim) - For the awesome UI framework
- [playerctl](https://github.com/altdesktop/playerctl) - For media player control
