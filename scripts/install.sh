#!/bin/bash

REPO=$1
INSTALL_DIR="/home/user/apps"

# Check if argument provided
if [ -z "$REPO" ]; then
    echo "Usage: install username/repo"
    exit 1
fi

echo "==============================="
echo "  Installing $REPO"
echo "==============================="

# Create install directory
mkdir -p "$INSTALL_DIR"

# Clone or update repo
if [ -d "$INSTALL_DIR/$REPO" ]; then
    echo "Already installed, updating..."
    cd "$INSTALL_DIR/$REPO" && git pull
else
    echo "Fetching from GitHub..."
    git clone https://github.com/$REPO "$INSTALL_DIR/$REPO"
fi

# Check if clone worked
if [ $? -ne 0 ]; then
    echo "Failed to fetch $REPO"
    echo "Check the username/repo is correct"
    exit 1
fi

cd "$INSTALL_DIR/$REPO"

echo ""
echo "==============================="
echo "  Detecting how to run..."
echo "==============================="

# Check for webvm.config first
if [ -f "webvm.config" ]; then
    echo "Found webvm.config!"
    source webvm.config

    # Install dependencies if specified
    if [ ! -z "$DEPENDENCIES" ]; then
        echo "Installing dependencies: $DEPENDENCIES"
        apt-get install -y $DEPENDENCIES 2>/dev/null
    fi

    # Run pip requirements if specified
    if [ ! -z "$PIP_REQUIREMENTS" ]; then
        echo "Installing pip requirements..."
        pip3 install -r $PIP_REQUIREMENTS 2>/dev/null
    fi

    # Run npm requirements if specified
    if [ ! -z "$NPM_INSTALL" ] && [ "$NPM_INSTALL" = "true" ]; then
        echo "Installing npm packages..."
        npm install 2>/dev/null
    fi

    # Run start command if specified
    if [ ! -z "$START_CMD" ]; then
        echo "Starting with: $START_CMD"
        eval $START_CMD
        exit 0
    fi
fi

# Auto detection fallback
echo "No webvm.config found, auto detecting..."
echo ""

# Check for common entry points in order of priority

# Python
if [ -f "main.py" ]; then
    echo "Found main.py, running with Python3..."
    # Install requirements if they exist
    if [ -f "requirements.txt" ]; then
        echo "Installing pip requirements..."
        pip3 install -r requirements.txt 2>/dev/null
    fi
    python3 main.py

elif [ -f "app.py" ]; then
    echo "Found app.py, running with Python3..."
    if [ -f "requirements.txt" ]; then
        pip3 install -r requirements.txt 2>/dev/null
    fi
    python3 app.py

elif [ -f "index.py" ]; then
    echo "Found index.py, running with Python3..."
    if [ -f "requirements.txt" ]; then
        pip3 install -r requirements.txt 2>/dev/null
    fi
    python3 index.py

# Node/JavaScript
elif [ -f "index.js" ]; then
    echo "Found index.js, running with Node..."
    if [ -f "package.json" ]; then
        echo "Installing npm packages..."
        npm install 2>/dev/null
    fi
    node index.js

elif [ -f "main.js" ]; then
    echo "Found main.js, running with Node..."
    if [ -f "package.json" ]; then
        npm install 2>/dev/null
    fi
    node main.js

elif [ -f "app.js" ]; then
    echo "Found app.js, running with Node..."
    if [ -f "package.json" ]; then
        npm install 2>/dev/null
    fi
    node app.js

# Shell Scripts
elif [ -f "run.sh" ]; then
    echo "Found run.sh, running..."
    chmod +x run.sh
    bash run.sh

elif [ -f "start.sh" ]; then
    echo "Found start.sh, running..."
    chmod +x start.sh
    bash start.sh

elif [ -f "main.sh" ]; then
    echo "Found main.sh, running..."
    chmod +x main.sh
    bash main.sh

# Ruby
elif [ -f "main.rb" ]; then
    echo "Found main.rb, running with Ruby..."
    if [ -f "Gemfile" ]; then
        echo "Installing gems..."
        gem install bundler 2>/dev/null
        bundle install 2>/dev/null
    fi
    ruby main.rb

elif [ -f "app.rb" ]; then
    echo "Found app.rb, running with Ruby..."
    if [ -f "Gemfile" ]; then
        gem install bundler 2>/dev/null
        bundle install 2>/dev/null
    fi
    ruby app.rb

# Lua
elif [ -f "main.lua" ]; then
    echo "Found main.lua, running with Lua..."
    lua5.4 main.lua

elif [ -f "index.lua" ]; then
    echo "Found index.lua, running with Lua..."
    lua5.4 index.lua

# Perl
elif [ -f "main.pl" ]; then
    echo "Found main.pl, running with Perl..."
    perl main.pl

# C/C++
elif [ -f "Makefile" ]; then
    echo "Found Makefile, building..."
    make
    # Try to run output
    if [ -f "./main" ]; then
        ./main
    elif [ -f "./app" ]; then
        ./app
    elif [ -f "./output" ]; then
        ./output
    else
        echo "Built successfully!"
        echo "No standard output binary found"
        echo "Check the apps directory for output"
    fi

elif [ -f "main.c" ]; then
    echo "Found main.c, compiling and running..."
    gcc main.c -o main
    ./main

elif [ -f "main.cpp" ]; then
    echo "Found main.cpp, compiling and running..."
    g++ main.cpp -o main
    ./main

# Java
elif [ -f "Main.java" ]; then
    echo "Found Main.java, compiling and running..."
    javac Main.java
    java Main

# Go
elif [ -f "main.go" ]; then
    echo "Found main.go, running with Go..."
    go run main.go

# PHP
elif [ -f "index.php" ]; then
    echo "Found index.php, running with PHP..."
    php index.php

elif [ -f "main.php" ]; then
    echo "Found main.php, running with PHP..."
    php main.php

else
    echo "==============================="
    echo "  Could not detect how to run!"
    echo "==============================="
    echo ""
    echo "Files in repository:"
    ls -la
    echo ""
    echo "Tip: Add a webvm.config to your"
    echo "repo to tell the installer how"
    echo "to run it!"
    echo ""
    echo "Example webvm.config:"
    echo "  START_CMD=\"python3 myscript.py\""
    echo "  DEPENDENCIES=\"curl wget\""
    exit 1
fi
