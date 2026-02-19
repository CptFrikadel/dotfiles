# Dependencies: `fd`, `bat, `rg`, `nufmt`.

# Directories
const alt_c = {
    name: fzf_dirs
    modifier: alt
    keycode: char_c
    mode: [emacs, vi_normal, vi_insert]
    event: [
      {
        send: executehostcommand
        cmd: "
          let result = fd --type directory --hidden | fzf;
          cd $result;
        "
      }
    ]
}

# History
const ctrl_r = {
  name: history_menu
  modifier: control
  keycode: char_r
  mode: [emacs, vi_insert, vi_normal]
  event: [
    {
      send: executehostcommand
      cmd: "
        let result = history
          | get command
          | str replace --all (char newline) ' '
          | to text
          | fzf --preview 'printf \'{}\' | nufmt --stdin 2>&1 | rg -v ERROR';
        commandline edit --append $result;
        commandline set-cursor --end
      "
    }
  ]
}

# Files
const ctrl_t =  {
    name: fzf_files
    modifier: control
    keycode: char_t
    mode: [emacs, vi_normal, vi_insert]
    event: [
      {
        send: executehostcommand
        cmd: "
          let result = fd --type file --hidden | fzf --preview 'bat --color=always --style=full --line-range=:500 {}';
          commandline edit --append $result;
          commandline set-cursor --end
        "
      }
    ]
}

# Update the $env.config
export-env {
  if not ($env.__keybindings_loaded? | default false) {
    $env.__keybindings_loaded = true
    $env.config.keybindings = $env.config.keybindings | append [
      $alt_c
      $ctrl_r
      $ctrl_t
    ]
  }
}
