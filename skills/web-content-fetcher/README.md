# Web Content Fetcher Skill for OpenClaw

Fetch and extract readable content from any URL. This skill wraps OpenClaw's built-in web_fetch functionality.

## Features

- Extract clean Markdown or plain text from web pages
- Automatic main content detection (removes ads, navigation, etc.)
- Configurable output length
- Built-in SSRF protection and redirect handling

## Usage

```javascript
const content = await web_fetch({
  url: "https://example.com",
  extractMode: "markdown", // or "text"
  maxChars: 10000, // optional, truncate long pages
});
```

## Parameters

- `url` (required): HTTP/HTTPS URL to fetch
- `extractMode` (optional): Output format, "markdown" (default) or "text"
- `maxChars` (optional): Maximum number of characters to return (default: 50000)

## Notes

- For JavaScript-heavy sites or pages requiring login, use the browser tool instead
- Responses are cached for 15 minutes by default
- Private/internal IP addresses are blocked for security
