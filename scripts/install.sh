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

    # Install apt dependencies if specified
    if [ ! -z "$DEPENDENCIES" ]; then
        echo "Installing dependencies: $DEPENDENCIES"
        apt-get install -y $DEPENDENCIES 2>/dev/null
    fi

    # Install pip requirements if specified
    if [ ! -z "$PIP_REQUIREMENTS" ]; then
        echo "Installing pip requirements..."
        pip3 install -r $PIP_REQUIREMENTS 2>/dev/null
    fi

    # Run npm install if specified
    if [ ! -z "$NPM_INSTALL" ] && [ "$NPM_INSTALL" = "true" ]; then
        echo "Installing npm packages..."
        npm install 2>/dev/null
    fi

    # Run cargo build if specified
    if [ ! -z "$CARGO_BUILD" ] && [ "$CARGO_BUILD" = "true" ]; then
        echo "Building with Cargo..."
        cargo build --release 2>/dev/null
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

# Python
if [ -f "main.py" ]; then
    echo "Found main.py, running with Python3..."
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

# TypeScript
elif [ -f "main.ts" ]; then
    echo "Found main.ts, running with ts-node..."
    if [ -f "package.json" ]; then
        npm install 2>/dev/null
    fi
    ts-node main.ts

elif [ -f "index.ts" ]; then
    echo "Found index.ts, running with ts-node..."
    if [ -f "package.json" ]; then
        npm install 2>/dev/null
    fi
    ts-node index.ts

elif [ -f "app.ts" ]; then
    echo "Found app.ts, running with ts-node..."
    if [ -f "package.json" ]; then
        npm install 2>/dev/null
    fi
    ts-node app.ts

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

# Package.json without obvious entry point
elif [ -f "package.json" ]; then
    echo "Found package.json, running with npm start..."
    npm install 2>/dev/null
    npm start

# Rust
elif [ -f "Cargo.toml" ]; then
    echo "Found Cargo.toml, building with Cargo..."
    cargo build --release
    if [ $? -eq 0 ]; then
        # Find and run the binary
        BINARY=$(find target/release -maxdepth 1 -type f -executable | head -1)
        if [ ! -z "$BINARY" ]; then
            echo "Running $BINARY..."
            $BINARY
        else
            echo "Built successfully!"
            echo "No binary found to run automatically"
        fi
    fi

# Java
elif [ -f "pom.xml" ]; then
    echo "Found pom.xml, building with Maven..."
    mvn package -q 2>/dev/null
    JAR=$(find target -name "*.jar" | head -1)
    if [ ! -z "$JAR" ]; then
        echo "Running $JAR..."
        java -jar $JAR
    fi

elif [ -f "build.gradle" ]; then
    echo "Found build.gradle, building with Gradle..."
    gradle build 2>/dev/null
    JAR=$(find build/libs -name "*.jar" | head -1)
    if [ ! -z "$JAR" ]; then
        echo "Running $JAR..."
        java -jar $JAR
    fi

elif [ -f "Main.java" ]; then
    echo "Found Main.java, compiling and running..."
    javac Main.java
    java Main

elif [ -f "App.java" ]; then
    echo "Found App.java, compiling and running..."
    javac App.java
    java App

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
        bundle install 2>/dev/null
    fi
    ruby main.rb

elif [ -f "app.rb" ]; then
    echo "Found app.rb, running with Ruby..."
    if [ -f "Gemfile" ]; then
        bundle install 2>/dev/null
    fi
    ruby app.rb

# Go
elif [ -f "main.go" ]; then
    echo "Found main.go, running with Go..."
    if [ -f "go.mod" ]; then
        go mod download 2>/dev/null
    fi
    go run main.go

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

# Haskell
elif [ -f "main.hs" ]; then
    echo "Found main.hs, compiling with GHC..."
    ghc main.hs -o main
    ./main

elif [ -f "Main.hs" ]; then
    echo "Found Main.hs, compiling with GHC..."
    ghc Main.hs -o main
    ./main

# R
elif [ -f "main.R" ]; then
    echo "Found main.R, running with R..."
    Rscript main.R

elif [ -f "index.R" ]; then
    echo "Found index.R, running with R..."
    Rscript index.R

# C/C++
elif [ -f "Makefile" ]; then
    echo "Found Makefile, building..."
    make
    if [ -f "./main" ]; then
        ./main
    elif [ -f "./app" ]; then
        ./app
    elif [ -f "./output" ]; then
        ./output
    else
        echo "Built successfully!"
        echo "No standard output binary found"
        ls -la
    fi

elif [ -f "CMakeLists.txt" ]; then
    echo "Found CMakeLists.txt, building with CMake..."
    mkdir -p build && cd build
    cmake .. 2>/dev/null
    make 2>/dev/null
    BINARY=$(find . -maxdepth 1 -type f -executable | head -1)
    if [ ! -z "$BINARY" ]; then
        $BINARY
    fi

elif [ -f "main.c" ]; then
    echo "Found main.c, compiling and running..."
    gcc main.c -o main
    ./main

elif [ -f "main.cpp" ]; then
    echo "Found main.cpp, compiling and running..."
    g++ main.cpp -o main
    ./main

# PHP
elif [ -f "index.php" ]; then
    echo "Found index.php, running with PHP..."
    php index.php

elif [ -f "main.php" ]; then
    echo "Found main.php, running with PHP..."
    php main.php

# Fortran
elif [ -f "main.f90" ]; then
    echo "Found main.f90, compiling with GFortran..."
    gfortran main.f90 -o main
    ./main

elif [ -f "main.f" ]; then
    echo "Found main.f, compiling with GFortran..."
    gfortran main.f -o main
    ./main

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
    echo "  PIP_REQUIREMENTS=\"requirements.txt\""
    echo "  NPM_INSTALL=\"true\""
    echo "  CARGO_BUILD=\"true\""
    exit 1
fi
