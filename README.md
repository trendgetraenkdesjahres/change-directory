# Change Directory Plugin for Zsh
This Zsh plugin, **`change-directory`**, enhances the built-in cd command by smart directory suggestions based on usage history.

## Installation
### Using Curl
To install the **`change-directory`** plugin to your defined **custom-zsh folder**, you can use the following one-liner with **`curl`**:
```bash
curl -fsSL https://raw.githubusercontent.com/change-directory/main/install.zsh | zsh
```
### Manual Installation
Alternatively, you can clone the repository manually to your zsh plugins directory:
```bash
git clone https://github.com/trendgetraenkdesjahres/change-directory.git
```
Then, add **`change-directory`** to the plugins list in your **`~/.zshrc`** file:
```bash
plugins=(
    dirhistory
    git
    artisan
    zsh-syntax-highlighting
    colored-man-pages
    change-directory
)
```
## Usage
The change-directory plugin adds a suggestion functionality to the cd command in Zsh. You can use the following options:
- `-h`: Show help message.
- `-L`: Change the logical working directory.
- `-P`: Change the physical working directory.
```bash
cd [OPTION] [DIRECTORY/Token] ...[optional: Token]
```

## Suggestion-Feature:
the ability of this plugin is to suggest directories based on your usage history. When providing partial directory names or tokens, the plugin suggests the most relevant directories. To use this feature, add a second word to your cd command. Now the command is considering the words as tokens, and not as path.

### Current Directory is Prioritized
- **Current Directory Suggestions:** If you provide only tokens (subdirectory names or just parts of them), the plugin suggests directories starting from the current working directory that match the provided tokens.
- **Global Suggestions:*** If the current directory does not match, the plugin looks for suggestions globally, considering all directories.

### Complete Directory Names are Prioritized
If the last token matches the a directory name Completely, it is prioritized.

### Priority by frequency and recency
If multiple paths that match your search items, the plugin will consider the frequency and the recency of the last time cd'ing there.

### Examples:
```bash
cd var html
```
will change your working directory to '/var/www/html'.

```bash
cd proj wordpress
```
will change your working directory to '/home/gilber/git-projects/wordpress'. The string 'proj' is imcomplete, but that is okay.

#### how does it work?
The plugin creates a file in where it stores the history of cd-operations.
Each entry contains the path, the path rating and the list time cd'ing there.
- it creates a new entry if the directory is not stored inside yet
- it updates the rating (relativ to the current rating and the last time cd'ing there)
- it deleted the entry if the cd was not succesfull (when the direcory is inaccessible)

## Options:
`-L`: Change the logical working directory.
`-P`: Change the physical working directory.
`-h`: Display help and exit.

# Agenda
- [] wenn als plugin geladen geht die _directory_file var nicht
- []  wieso gab es einen leeren pfad in der datei?
- []  "cd" soll zu home fuehren
- []  logik bei nur einem token - wann proposal, wann fehler?
- []  "Now in: $dir" message verbessern. ggf mit ls?
- []  config-file/ config option/ flag
- []  wenn mehr als ein token, sollte proposal auch aktiv nach pfaden suchen, wenn nichts im  _directory_file gefunden wurde?
- []  zsh completion

# About
The development of this plugin was a code challenge and an exercise in learning more about writing bash/zsh scripts. The plugin drew inspiration from [Zsh-z]([text](https://github.com/agkozak/zsh-z)), a tool I admired even though I never used it. I was initially hesitant to tinker with the cd command, but I wanted to try implementing a similar concept myself.

If you're interested in contributing, providing feedback, or submitting merge requests to help improve the plugin, please feel free to do so. Your input is highly appreciated.

## License
