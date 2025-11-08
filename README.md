# 🎵 snacks-music-player.nvim

A minimal, beautiful music player UI for Neovim using [folke/snacks.nvim](https://github.com/folke/snacks.nvim) and [playerctl](https://github.com/altdesktop/playerctl).

## 📹 Preview

<img width="614" height="287" alt="image" src="https://github.com/user-attachments/assets/f9ded456-6131-4262-8d43-4a0fcdd26af7" />

## ✨ Features

- 🎨 Clean horizontal UI with centered content
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
  "MannuVilasara/snacks-music-player.nvim",  -- Replace with your GitHub username
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

You can customize the appearance by overriding highlight groups in your colorscheme or init.lua:

```lua
vim.api.nvim_set_hl(0, "SnacksMusicPlayerBorder", { fg = "#89b4fa" })
vim.api.nvim_set_hl(0, "SnacksMusicPlayerTitle", { fg = "#cdd6f4", bold = true })
```

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
