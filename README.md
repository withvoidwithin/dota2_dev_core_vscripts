# Dota 2 Developer Utilities (vscripts)
My custom VScripts utility functions for Dota 2 custom game development.

## 1. Installation
To integrate this library into your Dota 2 custom game, add it as a Git submodule.    
Run the following command from the root directory of your main repository:    
``git submodule add <git_module> <your_preferred_folder_path>``

*The target folder must be located inside the **"vscripts"** directory!*

### Example
```bash
git submodule add https://github.com/withvoidwithin/dota2_dev_utils_vscripts dota_addon/game/scripts/vscripts/core
```

Resulting Directory Structure:
```
repository_root/
└── dota_addon/
    ├── content/
    └── game/
        └── scripts/
            └── vscripts/
                └── core/
                    ├── utils_server.lua
                    └── utils.lua
```

## 2. Usage in Code
```lua
local U = require("core/utils_server")

local value = U.Clamp(114, 1, 100)
```
