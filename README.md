# Azure Sample Function App

This project is a sample Azure Function App implemented in Python, demonstrating how to build and deploy an HTTP-triggered function using Azure Functions and Terraform for infrastructure provisioning.

---

## Project Overview

- **Azure Function**: A Python HTTP-triggered function named `HttpFunction` that returns a personalized greeting message. It accepts a `name` parameter via query string or JSON request body.
- **Infrastructure as Code**: Terraform scripts to provision the necessary Azure resources including a resource group, storage account, storage containers, and diagnostic storage tables.
- **Testing Client**: A simple Python script to invoke the Azure Function locally or remotely for testing.

---

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- [Terraform](https://www.terraform.io/downloads.html)
- Python 3.8 or later
- Azure Functions Core Tools (for local development)
- An Azure subscription

---

## Setup and Deployment

### 1. Clone the Repository

```bash
git clone <repository-url>
cd azure-sample-function-app
```

### 2. Provision Azure Infrastructure

Terraform scripts are located in the root directory.

```bash
terraform init
terraform apply
```

This will create:

- Resource group `rg-funcapp-test`
- Storage account and containers needed for the Function App
- Storage share and diagnostic tables

### 3. Install Python Dependencies

Navigate to the `src` directory and install dependencies:

```bash
cd src
pip install -r requirements.txt
```

### 4. Run the Function App Locally

Ensure Azure Functions Core Tools is installed. Run the function app:

```bash
func start
```

The function will be available at:

```
http://localhost:7071/api/HttpFunction
```

You can test with a query parameter, e.g.:

```
http://localhost:7071/api/HttpFunction?name=Artem
```

### 5. Deploy the Function App to Azure

Follow Azure Functions deployment best practices (not included in this repo). You can use Azure CLI or VS Code Azure Functions extension to deploy.

---

## Usage

The function responds with a greeting message:

- If `name` is provided in query string or JSON body, it returns:  
  `"Hello, {name}. This HTTP triggered function executed successfully."`
- Otherwise, it returns a generic success message.

---

## Testing

The `src/test_main.py` script acts as a client to test the function locally or remotely.

Usage:

```bash
python src/test_main.py -local
```

This calls the local function endpoint. To test the deployed Azure function, omit the `-local` flag. Update the URL and function key in the script as needed.

---

## Project Structure

```
.
├── main.tf               # Terraform main configuration
├── provider.tf           # Terraform provider configuration
├── src/
│   ├── function_app.py   # Azure Function app implementation
│   ├── host.json         # Azure Functions runtime configuration
│   ├── requirements.txt  # Python dependencies
│   └── test_main.py      # Test client script
```

---

## Notes

- The Terraform storage account name and resource group are hardcoded and may require modification for uniqueness.
- The function uses Azure Functions Python worker managed by the platform; do not manually manage `azure-functions-worker`.
- The project uses Azure Functions extension bundle version 4.x.

---

## License

[MIT License](LICENSE) (if applicable)