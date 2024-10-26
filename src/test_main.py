import argparse
import requests

def main(is_local):
    if is_local:
        url = "http://localhost:7071/api/HttpFunction"  # Local function URL
    else:
        url = "https://function-app-kozlenkov-test.azurewebsites.net/api/HttpFunction?code=XAd7aJ8dNRgojh6m5-LcK7s2r7CJgIqZ2BZGsv0CurvhAzFuH4uTfw%3D%3D"  # Replace with your function app URL
    
    # Example payload (if needed)
    payload = {"name": "Artem"}  # Adjust as necessary
    response = requests.get(url, json=payload)  # Use post() if required

    # Print response details
    print(f"Response Code: {response.status_code}")
    print(f"Response Body: {response.text}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run the Azure Function client.')
    parser.add_argument('-local', action='store_true', help='Use local HTTP endpoint')
    
    args = parser.parse_args()
    
    main(args.local)
