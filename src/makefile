# Variables
RESOURCE_GROUP = rg-funcapp-test
FUNCTION_APP_NAME = function-app-kozlenkov-test
ZIP_FILE = function.zip
SOURCE_DIR = .
PYTHON_PACKAGES_DIR = .python_packages/lib/site-packages

# Requirements file
REQUIREMENTS_FILE = requirements.txt

# Targets
.PHONY: all clean package deploy dependencies

all: clean dependencies package deploy

clean:
	@echo "Cleaning up..."
	rm -rf $(ZIP_FILE) $(PYTHON_PACKAGES_DIR)

dependencies:
	@echo "Installing Python dependencies..."
	mkdir -p $(PYTHON_PACKAGES_DIR)
	pip install --target=$(PYTHON_PACKAGES_DIR) -r $(REQUIREMENTS_FILE)

package:
	@echo "Packaging function app..."
	zip -r $(ZIP_FILE) $(SOURCE_DIR) $(PYTHON_PACKAGES_DIR)

deploy: package
	@echo "Deploying to Azure..."
	az functionapp deployment source config-zip \
		--resource-group $(RESOURCE_GROUP) \
		--name $(FUNCTION_APP_NAME) \
		--src $(ZIP_FILE)
