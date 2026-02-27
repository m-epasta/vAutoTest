# autoTest Justfile

# Build the project
build:
    v -o autoTest src/

# Run tests
test: build
    v test tests/

# Format code
fmt:
    v fmt -w src/*.v
    v fmt -w tests/*.v

# Build and run
run: build
    ./autoTest

# Clean workspace
clean:
    rm -f autoTest
    rm -rf tests/*.tmp

project_dir := justfile_directory()

install: build
    @if ! echo "$$PATH" | grep -q "{{ project_dir }}"; then \
        if ! grep -q "{{ project_dir }}" ~/.bashrc; then \
            echo "export PATH=\"{{ project_dir }}:\$PATH\"" >> ~/.bashrc; \
            echo "Added {{ project_dir }} to ~/.bashrc"; \
        fi; \
        echo "Please run 'source ~/.bashrc' or restart your terminal to use 'autoTest' anywhere."; \
    else \
        echo "autoTest is already in your PATH."; \
    fi
