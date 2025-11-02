# Makefile for Embers of the Earth

.PHONY: help build test sim profile clean

help:
	@echo "Available targets:"
	@echo "  make build     - Build the project"
	@echo "  make test      - Run tests"
	@echo "  make sim       - Run balance simulator"
	@echo "  make profile   - Profile the game"
	@echo "  make clean     - Clean build artifacts"

build:
	@echo "Building project..."
	@mkdir -p builds
	# Godot export would go here

test:
	@echo "Running tests..."
	@python tools/sim/balance_simulator.py

sim:
	@echo "Running balance simulations..."
	@python tools/sim/balance_simulator.py

profile:
	@echo "Profiling game..."
	@mkdir -p reports
	# Godot profiler would be called here
	@echo "Profile data saved to reports/"

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf builds/
	@rm -rf reports/
	@rm -rf .godot/
