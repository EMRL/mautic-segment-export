# Mautic Segment Export

A simple Bash script for exporting all contacts from a specific Mautic segment to CSV using the Mautic REST API.

The script automatically works through the complete segment, so there is no need to manually specify a contact limit or page size.

## Requirements

The script requires:

- Bash
- `curl`
- `jq`
- Access to the Mautic REST API
- Mautic credentials with permission to read contacts

## Configuration

Edit the configuration values at the top of `mtc-export.sh`:

```bash
MAUTIC="https://engage.yourdomain.com"
USER="user"
PASS="pass"

SEGMENT="segment-alias"
```

### Mautic URL

Set `MAUTIC` to the base URL of your Mautic installation.

```bash
MAUTIC="https://engage.example.com"
```

Do not include `/api` at the end.

### Credentials

Set `USER` and `PASS` to credentials that can access the Mautic API.

```bash
USER="api-user"
PASS="password"
```

### Segment

`SEGMENT` must contain the **segment alias**, not the segment name.

For example, if the segment is named:

```text
Monthly Newsletter Subscribers
```

and its alias is:

```text
monthly-newsletter
```

use:

```bash
SEGMENT="monthly-newsletter"
```

## Usage

Make the script executable:

```bash
chmod +x mtc-export.sh
```

Then run it:

```bash
./mtc-export.sh
```

The script retrieves contacts from Mautic until the entire segment has been exported.

Progress is displayed while the export runs:

```text
Exported 30 of 247 contacts...
Exported 60 of 247 contacts...
Exported 90 of 247 contacts...
```

When complete:

```text
Done. Exported 247 contacts to contacts-monthly-newsletter.csv
```

## Output

The generated CSV file is named using the segment alias:

```text
contacts-SEGMENT.csv
```

For example:

```text
contacts-monthly-newsletter.csv
```

The CSV currently contains the following fields:

```text
id
firstname
lastname
email
phone
company
```

Additional Mautic contact fields can be added by modifying the `jq` section of the script.

For example:

```bash
.contacts[] |
[
    .id,
    .fields.all.firstname,
    .fields.all.lastname,
    .fields.all.email,
    .fields.all.phone,
    .fields.all.company
] | @csv
```

## How it works

The script queries:

```text
/api/contacts
```

using Mautic's contact search syntax:

```text
segment:segment-alias
```

It reads the number of contacts returned and Mautic's reported total, then advances the API `start` value until all contacts have been retrieved.

## Security

The current script stores the Mautic username and password directly in `mtc-export.sh`. 

Do not commit real credentials to a public repository. For shared or production use, consider moving credentials to environment variables or another secure configuration method.
