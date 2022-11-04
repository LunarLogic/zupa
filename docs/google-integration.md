# Google Integration

This document covers all Google-related integrations in the application.

## Google Drive Integration

The app uses Google Drive API with a service account to fetch spreadsheets for trip creation.

### Setup for Development

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a project (or use an existing one)
3. Enable the **Google Drive API** and **Google Sheets API**:
   - Go to APIs & Services > Enable APIs
   - Search for and enable both APIs
4. Create a service account:
   - Go to IAM & Admin > Service Accounts
   - Click "Create Service Account"
   - Give it a name and description
   - Click "Create and Continue"
   - Skip the optional permissions steps
5. Create a JSON key for the service account:
   - Click on the service account you just created
   - Go to the "Keys" tab
   - Click "Add Key" > "Create new key"
   - Choose JSON format
   - Download the JSON file
6. Fill in the `GOOGLE_DRIVE_*` variables in `.env.development` with values from the JSON file:
   ```
   GOOGLE_DRIVE_CLIENT_ID=<"client_id" from JSON>
   GOOGLE_DRIVE_CLIENT_CERT_URL=<"client_x509_cert_url" from JSON>
   GOOGLE_DRIVE_PRIVATE_KEY_ID=<"private_key_id" from JSON>
   GOOGLE_DRIVE_PRIVATE_KEY=<"private_key" from JSON - see formatting below>
   GOOGLE_DRIVE_PROJECT_ID=<"project_id" from JSON>
   GOOGLE_DRIVE_CLIENT_EMAIL=<"client_email" from JSON>
   ```
7. Format the `GOOGLE_DRIVE_PRIVATE_KEY` as a single line with `\n` escape sequences (double-quoted):
   ```
   GOOGLE_DRIVE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIE...\n-----END PRIVATE KEY-----\n"
   ```
8. **Share your Google Sheets with the service account email** (`GOOGLE_DRIVE_CLIENT_EMAIL`)
   - This is the step people usually miss!
   - The service account has its own email (something like `my-service@my-project.iam.gserviceaccount.com`)
   - Open your Google Sheet, click "Share", and add this email with Viewer access

### Important Notes

- The private key must be double-quoted with literal `\n` characters (backslash-n, not actual newlines)
- The app normalizes these to real newlines internally to handle different environment loading behaviors (foreman vs direct Rails boot)
- Without sharing the spreadsheet with the service account email, you'll get "File not found" errors

### Testing

For test environment (`.env.test`), the `GOOGLE_DRIVE_PRIVATE_KEY` must be a valid RSA key because the Google Drive client parses it before VCR can intercept HTTP calls. Generate a dummy key:

```shell
openssl genrsa 2048 | awk '{printf "%s\\n", $0}' | sed 's/\\n$//'
```

Paste the output as the `GOOGLE_DRIVE_PRIVATE_KEY` value in `.env.test`.

### Production Setup

Secrets are stored in AWS Secrets Manager. When editing `GOOGLE_DRIVE_PRIVATE_KEY` in AWS Secrets Manager, switch to **Plaintext mode** and paste the key value with `\n` as newlines. This will ensure the key is properly formatted and read by the app.

## Google Maps Integration

**Note:** Currently not actively used in the application.

The app uses React Google Maps API for displaying map snapshots and location features.

### Setup for Development

To create a new Google Maps API key:

1. Go to the [Google Maps Platform](https://cloud.google.com/maps-platform)
2. Click the Get Started button in the middle of the screen
3. Click on the Google Cloud Platform home in the upper left corner
4. Click on Billing to make sure your billing details are up-to-date. If they are not, your Google Maps will not work properly
5. Once you've confirmed your billing is up-to-date, click on the Google Cloud Platform home in upper left corner again
6. Hover to APIs & Services and go to Credentials
7. Select 'Create a new project' and enter a project name (or use existing project)
8. Click Create credentials and select API key. You will see a new dialog that displays the newly created API key
9. Paste the key to your `.env.development` file:
   ```
   REACT_APP_GOOGLE_MAPS_API_KEY=your_api_key_here
   ```
10. Save the file and restart the development server

### Documentation

- React Google Maps library: https://react-google-maps-api-docs.netlify.app/
