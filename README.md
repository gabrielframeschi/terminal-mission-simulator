# Terminal Mission Simulator

An interactive Bash script that pretends to be a spacecraft diagnostics system (SDPS) for the
Artemis mission. Underneath it is `cat`, `wc` and `grep` over a sample log file — the mission
framing is flavor, not function.

Written on Ubuntu as practice for the Alura course
"_Terminal: aprenda comandos para executar tarefas_".

## What it does

On startup it plays a fake handshake — secure link, data transfer, processing — and then opens a
`select` menu:

| Option                        | What actually runs                                                 |
| ----------------------------- | ------------------------------------------------------------------ |
| `View logs`                   | `cat` over the mission log                                         |
| `Diagnostics`                 | `wc`, reported as a "data integrity check"                         |
| `Detect errors and anomalies` | `grep -i` for `error`, `alert` and `corrupted_log`, matches in red |
| `Exit`                        | closes the session                                                 |

Every step is dressed up with spinners, a typewriter effect and ANSI colors.

## Running it

```bash
git clone https://github.com/gabrielframeschi/terminal-mission-simulator.git
cd terminal-mission-simulator
./script.sh
```

It can be run from any directory — the script resolves the log file relative to its own location.

## Requirements

- Bash 4.2 or newer
- A terminal with ANSI color support
- `tput`, `cat`, `wc`, `grep` — standard on any Linux or macOS install

## Layout

```
├── script.sh          # the whole program
├── original_files/
│   └── file_1.txt     # sample Artemis mission log
├── README.md
└── LICENSE
```

## License

Released under the [MIT License](LICENSE).

---

_Educational project: a terminal playground, not a real diagnostics tool._
